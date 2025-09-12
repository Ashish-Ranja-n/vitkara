import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import dbConnect from '../../../../lib/db';
import Investor from '../../../../models/Investor';

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

export async function POST(request: NextRequest) {
  const investor = await getCurrentUser(request);

  if (!investor) {
    return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
  }

  // Log the logout event (optional)
  console.log(`User ${investor._id} (${investor.name}) logged out`);

  // Return success response
  // The client will handle clearing local tokens
  return NextResponse.json({
    message: 'Logged out successfully',
    success: true
  });
}
