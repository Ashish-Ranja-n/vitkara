import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import dbConnect from '../../../lib/db';
import Investor from '../../../models/Investor';

interface JWTPayload {
  id: string;
}

async function getCurrentUser(request: NextRequest) {
  const authHeader = request.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7);
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;
    await dbConnect();
    const investor = await Investor.findById(decoded.id);
    return investor;
  } catch {
    return null;
  }
}

export async function GET(request: NextRequest) {
  const investor = await getCurrentUser(request);
  if (!investor) {
    return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
  }

  return NextResponse.json({
    id: investor._id,
    name: investor.name,
    email: investor.email,
    avatar: investor.avatar,
    age: investor.age,
    location: investor.location,
    verified: investor.verified,
    totalInvestment: investor.totalInvestment,
    walletBalance: investor.walletBalance,
    defaultDashboard: investor.defaultDashboard,
    createdAt: investor.createdAt,
  });
}

export async function PUT(request: NextRequest) {
  const investor = await getCurrentUser(request);
  if (!investor) {
    return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
  }

  const body = await request.json();
  const { name, avatar, age, location, defaultDashboard, totalInvestment, walletBalance } = body;

  if (name !== undefined) investor.name = name;
  if (avatar !== undefined) investor.avatar = avatar;
  if (age !== undefined) investor.age = age;
  if (location !== undefined) investor.location = location;
  if (defaultDashboard !== undefined) investor.defaultDashboard = defaultDashboard;
  if (totalInvestment !== undefined) investor.totalInvestment = totalInvestment;
  if (walletBalance !== undefined) investor.walletBalance = walletBalance;

  await investor.save();

  return NextResponse.json({
    id: investor._id,
    name: investor.name,
    email: investor.email,
    avatar: investor.avatar,
    age: investor.age,
    location: investor.location,
    verified: investor.verified,
    totalInvestment: investor.totalInvestment,
    walletBalance: investor.walletBalance,
    defaultDashboard: investor.defaultDashboard,
    createdAt: investor.createdAt,
  });
}
