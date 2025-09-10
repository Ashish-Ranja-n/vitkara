import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import { verifyGoogleToken } from '../../../../lib/auth';
import jwt from 'jsonwebtoken';
export async function POST(request: Request) {
  const { idToken } = await request.json();

  if (!idToken) {
    return NextResponse.json({ message: 'Missing token' }, { status: 400 });
  }

  await dbConnect();

  const result = await verifyGoogleToken(idToken);

  if (!result) {
    return NextResponse.json({ message: 'Invalid token' }, { status: 401 });
  }

  const { investor, isNew } = result;

  const accessToken = jwt.sign({ id: investor._id }, process.env.JWT_SECRET!, {
    expiresIn: '1d',
  });
  const refreshToken = jwt.sign({ id: investor._id }, process.env.JWT_REFRESH_SECRET!, {
    expiresIn: '7d',
  });


  return NextResponse.json({
    accessToken,
    refreshToken,
    user: investor,
    isNew,
  });
}
