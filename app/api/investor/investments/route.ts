import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import dbConnect from '@/lib/db';
import Investor from '@/models/Investor';
import Investment from '@/models/Investment';
import InvestmentCampaign from '@/models/InvestmentCampaign';
import Shop from '@/models/shop';

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

  try {
    await dbConnect();

    // Find all investments for this investor
    const investments = await Investment.find({ investorId: investor._id })
      .populate({
        path: 'campaignId',
        populate: {
          path: 'shopId',
          model: 'Shop',
          select: 'name location avgUpiTransactions',
        },
      })
      .sort({ purchaseDate: -1 });

    return NextResponse.json({
      investments: investments.map(inv => ({
        _id: inv._id,
        amount: inv.amount,
        shares: inv.shares,
        expectedReturns: inv.expectedReturns,
        purchaseDate: inv.purchaseDate,
        status: inv.status,
        campaignId: {
          _id: inv.campaignId._id,
          name: inv.campaignId.name,
          shopId: {
            _id: inv.campaignId.shopId._id,
            name: inv.campaignId.shopId.name,
            location: inv.campaignId.shopId.location,
          },
        },
      })),
      success: true,
    });
  } catch (error) {
    console.error('Fetching investments error:', error);
    return NextResponse.json(
      {
        message: 'Internal server error',
        success: false,
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  const investor = await getCurrentUser(request);
  if (!investor) {
    return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { campaignId, tickets } = body;

    if (!campaignId || !tickets) {
      return NextResponse.json(
        { message: 'Campaign ID and number of tickets are required' },
        { status: 400 }
      );
    }

    // Validate campaignId format
    if (!mongoose.Types.ObjectId.isValid(campaignId)) {
      return NextResponse.json(
        { message: 'Invalid campaign ID format' },
        { status: 400 }
      );
    }

    if (tickets < 1 || !Number.isInteger(tickets)) {
      return NextResponse.json(
        { message: 'Number of tickets must be a positive integer' },
        { status: 400 }
      );
    }

    await dbConnect();

    console.log('Received shopId (used as campaignId):', campaignId);

    // Find the active campaign for this shop
    const campaign = await InvestmentCampaign.findOne({ shopId: campaignId, status: 'active' });
    console.log('Found campaign:', campaign);
    if (!campaign) {
      return NextResponse.json(
        { message: 'Campaign not found' },
        { status: 404 }
      );
    }

    // Check if campaign is active
    if (campaign.status !== 'active') {
      return NextResponse.json(
        { message: 'Campaign is not active' },
        { status: 400 }
      );
    }

    // Calculate investment amount (tickets * ticket price)
    const ticketPrice = campaign.minInvestment; // ticket price is min investment
    const amount = tickets * ticketPrice;

    // Check investment limits
    if (amount > campaign.maxInvestment) {
      return NextResponse.json(
        {
          message: `Investment amount (${amount}) exceeds maximum allowed (${campaign.maxInvestment})`
        },
        { status: 400 }
      );
    }

    // Check if investor has sufficient balance
    if (investor.walletBalance < amount) {
      return NextResponse.json(
        { message: 'Insufficient wallet balance' },
        { status: 400 }
      );
    }

    // Check if investment would exceed target
    if (campaign.currentAmount + amount > campaign.targetAmount) {
      return NextResponse.json(
        { message: 'Investment would exceed campaign target' },
        { status: 400 }
      );
    }

    // Calculate shares (1 share per ticket)
    const shares = tickets;

    // Create investment
    const investment = await Investment.create({
      investorId: investor._id,
      campaignId: campaign._id,
      amount,
      shares,
      expectedReturns: amount * campaign.expectedROI,
    });

    // Update campaign current amount
    campaign.currentAmount += amount;
    if (campaign.currentAmount >= campaign.targetAmount) {
      campaign.status = 'funded';
    }
    await campaign.save();

    // Update investor balance and total investment
    investor.walletBalance -= amount;
    investor.totalInvestment += amount;
    await investor.save();

    return NextResponse.json({
      investment: {
        id: investment._id,
        amount: investment.amount,
        shares: investment.shares,
        tickets: tickets,
        expectedReturns: investment.expectedReturns,
        purchaseDate: investment.purchaseDate,
        status: investment.status,
      },
      campaign: {
        id: campaign._id,
        currentAmount: campaign.currentAmount,
        status: campaign.status,
      },
      investor: {
        walletBalance: investor.walletBalance,
        totalInvestment: investor.totalInvestment,
      },
      success: true,
    });

  } catch (error) {
    console.error('Investment creation error:', error);
    return NextResponse.json(
      {
        message: 'Internal server error',
        success: false,
      },
      { status: 500 }
    );
  }
}
