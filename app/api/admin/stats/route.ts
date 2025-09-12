import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import Admin from '@/models/admin';
import Investor from '@/models/Investor';
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
    } catch (error) {
      return NextResponse.json(
        { message: 'Invalid token' },
        { status: 401 }
      );
    }

    const [totalInvestors, totalShops, totalAdmins] = await Promise.all([
      Investor.countDocuments(),
      Shop.countDocuments(),
      Admin.countDocuments(),
    ]);

    return NextResponse.json({
      totalInvestors,
      totalShops,
      totalAdmins,
    });
  } catch (error) {
    console.error('Stats error:', error);
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}
