import { NextRequest, NextResponse } from 'next/server';
import Admin from '@/models/admin';
import dbConnect from '@/lib/db';

export async function POST(request: NextRequest) {
  try {
    await dbConnect();

    const { email, password, name, secret } = await request.json();

    // Simple security check - in production, use proper auth
    if (secret !== process.env.ADMIN_SECRET || !secret) {
      return NextResponse.json(
        { message: 'Unauthorized' },
        { status: 401 }
      );
    }

    if (!email || !password || !name) {
      return NextResponse.json(
        { message: 'Email, password, and name are required' },
        { status: 400 }
      );
    }

    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return NextResponse.json(
        { message: 'Admin already exists' },
        { status: 400 }
      );
    }

    const admin = new Admin({
      email,
      password,
      name,
    });

    await admin.save();

    return NextResponse.json(
      { message: 'Admin created successfully' },
      { status: 201 }
    );
  } catch (error) {
    console.error('Register error:', error);
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}
