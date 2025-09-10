import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import Otp from '../../../../models/Otp';
import Investor from '../../../../models/Investor';
import jwt from 'jsonwebtoken';

export async function POST(request: Request) {
  const { email, otp } = await request.json();

  if (!email || !otp) {
    return NextResponse.json({ message: 'Missing email or otp' }, { status: 400 });
  }

  await dbConnect();

  const otpEntry = await Otp.findOne({ email, otp });

  if (!otpEntry) {
    return NextResponse.json({ message: 'Invalid OTP' }, { status: 401 });
  }

  await Otp.deleteOne({ _id: otpEntry._id });

  let investor = await Investor.findOne({ email });
  let isNew = false;

  if (!investor) {
    investor = await Investor.create({
      email,
      name: email.split('@')[0], // default name
    });
    isNew = true;
  }

  const token = jwt.sign({ id: investor._id }, process.env.JWT_SECRET!, {
    expiresIn: '7d',
  });

  return NextResponse.json({ token, investor, isNew });
}
