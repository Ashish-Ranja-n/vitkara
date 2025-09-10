import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import { verifyGoogleToken } from '../../../../lib/auth';
import jwt from 'jsonwebtoken';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const idToken = body?.idToken;

    if (!idToken) {
      return NextResponse.json({ message: 'Missing token' }, { status: 400 });
    }

    await dbConnect();

    const result = await verifyGoogleToken(idToken);

    if (!result) {
      return NextResponse.json({ message: 'Invalid token' }, { status: 401 });
    }

    const { investor, isNew } = result;

    const jwtSecret = process.env.JWT_SECRET;
    const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET;
    if (!jwtSecret || !jwtRefreshSecret) {
      return NextResponse.json({ message: 'Server not configured: missing JWT secrets' }, { status: 500 });
    }

    const accessToken = jwt.sign({ id: investor._id }, jwtSecret, {
      expiresIn: '1d',
    });
    const refreshToken = jwt.sign({ id: investor._id }, jwtRefreshSecret, {
      expiresIn: '7d',
    });

    // sanitize user object
    const user = investor.toObject ? investor.toObject() : investor;
    delete (user as any).password;
    delete (user as any).__v;

    return NextResponse.json({
      accessToken,
      refreshToken,
      user,
      isNew,
    });
  } catch (err) {
    console.error('Google auth error:', err);
    return NextResponse.json({ message: 'Internal server error' }, { status: 500 });
  }
}
