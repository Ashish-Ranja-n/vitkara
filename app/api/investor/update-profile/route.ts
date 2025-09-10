import { NextResponse } from 'next/server';
import dbConnect from '../../../../lib/db';
import Investor from '../../../../models/Investor';
import { IInvestor } from '../../../../models/Investor';
import { protect } from '../../../../lib/auth';
import { NextRequest } from 'next/server';

async function handler(req: NextRequest & { user: IInvestor }) {
  const { name, age, location } = await req.json();

  if (!name || !age || !location) {
    return NextResponse.json({ message: 'Missing fields' }, { status: 400 });
  }

  await dbConnect();

  const investor = await Investor.findById(req.user.id);

  if (!investor) {
    return NextResponse.json({ message: 'Investor not found' }, { status: 404 });
  }

  investor.name = name;
  investor.age = age;
  investor.location = location;
  await investor.save();

  return NextResponse.json({ investor });
}

export const POST = protect(handler);
