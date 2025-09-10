import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import Otp from '../../../../models/Otp';
import nodemailer from 'nodemailer';

export async function POST(request: Request) {
  const { email } = await request.json();

  if (!email) {
    return NextResponse.json({ message: 'Missing email' }, { status: 400 });
  }

  await dbConnect();

  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  await Otp.create({ email, otp });

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  try {
    await transporter.sendMail({
      from: 'no-reply@vitkara.com',
      to: email,
      subject: 'Your OTP for Vitkara',
      text: `Your OTP is ${otp}`,
    });

    return NextResponse.json({ message: 'OTP sent' });
  } catch (error) {
    console.error('Error sending email:', error);
    return NextResponse.json({ message: 'Error sending OTP' }, { status: 500 });
  }
}
