import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import Investor from '../../../../models/Investor';
import { OAuth2Client } from 'google-auth-library';
import jwt from 'jsonwebtoken';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export async function POST(request: Request) {
  try {
    const body: unknown = await request.json();
    if (!body || typeof body !== 'object' || !('idToken' in body)) {
      return NextResponse.json({ message: 'Missing token' }, { status: 400 });
    }
    const { idToken } = body as { idToken: string };
    if (!idToken) {
      return NextResponse.json({ message: 'Missing token' }, { status: 400 });
    }

    await dbConnect();

    // Verify Google token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    if (!payload || !payload.email || !payload.name) {
      return NextResponse.json({ message: 'Invalid Google token' }, { status: 401 });
    }

    const { email, name, picture } = payload;

    // Check if investor exists
    let investor = await Investor.findOne({ email });
    let isNew = false;
    if (!investor) {
      investor = await Investor.create({
        email,
        name,
        avatar: picture,
      });
      isNew = true;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      return NextResponse.json({ message: 'Server not configured: missing JWT secret' }, { status: 500 });
    }

    // Prepare JWT payload for mobile app (email, name)
    const tokenPayload = {
      id: investor._id,
      email: investor.email,
      name: investor.name,
    };
    const accessToken = jwt.sign(tokenPayload, jwtSecret, { expiresIn: '7d' });

    // Sanitize user object
    const user = investor.toObject ? investor.toObject() : investor;
    delete (user as unknown as Record<string, unknown>).password;
    delete (user as unknown as Record<string, unknown>).__v;

    return NextResponse.json({
      accessToken,
      user,
      isNew,
    });
  } catch (err) {
    console.error('Google auth error:', err);
    return NextResponse.json({ message: 'Internal server error' }, { status: 500 });
  }
}
