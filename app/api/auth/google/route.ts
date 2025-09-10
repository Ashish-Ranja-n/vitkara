import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import Investor from '../../../../models/Investor';
import jwt from 'jsonwebtoken';

export async function POST(request: Request) {
  try {
    const body: unknown = await request.json();
    if (
      !body ||
      typeof body !== 'object' ||
      !('email' in body) ||
      !('displayName' in body)
    ) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      );
    }

    const { email, displayName, photoUrl } = body as {
      email: string;
      displayName: string;
      photoUrl?: string;
    };

    if (!email || !displayName) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      );
    }

    await dbConnect();

    // Check if investor exists
    let investor = await Investor.findOne({ email });
    let isNew = false;
    if (!investor) {
      investor = await Investor.create({
        email,
        name: displayName,
        avatar: photoUrl,
      });
      isNew = true;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      return NextResponse.json(
        { success: false, message: 'Server not configured: missing JWT secret' },
        { status: 500 }
      );
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
      success: true,
      token: accessToken,
      user,
      isNew,
    });
  } catch (err) {
    console.error('Google auth error:', err);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}
