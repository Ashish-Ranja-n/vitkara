import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import Shop from '@/models/shop';
import dbConnect from '@/lib/db';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    const token = request.cookies.get('admin-token')?.value;

    if (!token) {
      return NextResponse.json(
        { message: 'Unauthorized' },
        { status: 401 }
      );
    }

    try {
      jwt.verify(token, JWT_SECRET);
    } catch {
      return NextResponse.json(
        { message: 'Invalid token' },
        { status: 401 }
      );
    }

    const shops = await Shop.find()
      .select('name email location totalRaised activeCampaigns verified createdAt')
      .sort({ createdAt: -1 });

    return NextResponse.json({ shops });
  } catch {
    console.error('Get shops error');
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect();

    const token = request.cookies.get('admin-token')?.value;

    if (!token) {
      return NextResponse.json(
        { message: 'Unauthorized' },
        { status: 401 }
      );
    }

    try {
      jwt.verify(token, JWT_SECRET);
    } catch {
      return NextResponse.json(
        { message: 'Invalid token' },
        { status: 401 }
      );
    }

    const { name, email, location, owner, verified = true } = await request.json();

    // Validate required fields
    if (!name || !email || !owner) {
      return NextResponse.json(
        { message: 'Name, email, and owner are required' },
        { status: 400 }
      );
    }

    // Check if shop with this email already exists
    const existingShop = await Shop.findOne({ email });
    if (existingShop) {
      return NextResponse.json(
        { message: 'Shop with this email already exists' },
        { status: 400 }
      );
    }

    // Create new shop
    const shop = new Shop({
      name,
      email,
      location,
      owner,
      verified,
    });

    await shop.save();

    return NextResponse.json(
      {
        message: 'Shop created successfully',
        shop: {
          id: shop._id,
          name: shop.name,
          email: shop.email,
          verified: shop.verified,
        }
      },
      { status: 201 }
    );
  } catch {
    console.error('Create shop error');
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}
