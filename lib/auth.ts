import { OAuth2Client } from 'google-auth-library';
import Investor, { IInvestor } from '../models/Investor';
import jwt from 'jsonwebtoken';
import { NextRequest, NextResponse } from 'next/server';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

type AuthenticatedRequest = NextRequest & {
  user: IInvestor;
};

type Handler = (req: AuthenticatedRequest, ...args: any[]) => Promise<NextResponse>;

export function protect(handler: Handler) {
  return async (req: NextRequest, ...args: any[]) => {
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ message: 'Not authorized, no token' }, { status: 401 });
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { id: string };
      const user = await Investor.findById(decoded.id).select('-password');
      if (!user) {
        return NextResponse.json({ message: 'User not found' }, { status: 401 });
      }
      const authenticatedReq = req as AuthenticatedRequest;
      authenticatedReq.user = user;
      return handler(authenticatedReq, ...args);
    } catch (error) {
      return NextResponse.json({ message: 'Not authorized, token failed' }, { status: 401 });
    }
  };
}

export async function verifyGoogleToken(token: string): Promise<{ investor: IInvestor; isNew: boolean } | null> {
  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();

    if (!payload) {
      return null;
    }

    const { sub: googleId, name, email, picture: avatar } = payload;

    if (!name || !email) {
      return null;
    }

    let investor = await Investor.findOne({ googleId });
    let isNew = false;

    if (!investor) {
      investor = await Investor.create({
        googleId,
        name,
        email,
        avatar,
      });
      isNew = true;
    }

    return { investor, isNew };
  } catch (error) {
    console.error('Error verifying Google token:', error);
    return null;
  }
}
