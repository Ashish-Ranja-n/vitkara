import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import InvestmentCampaign from '@/models/InvestmentCampaign';
import Shop from '@/models/shop';
import dbConnect from '@/lib/db';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

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
    } catch (error) {
      return NextResponse.json(
        { message: 'Invalid token' },
        { status: 401 }
      );
    }

    const {
      shopId,
      title,
      description,
      targetAmount,
      minInvestment,
      maxInvestment,
      expectedROI,
      duration,
      dailyRepaymentPercentage,
      startDate,
      endDate,
    } = await request.json();

    // Validate required fields
    if (!shopId || !title || !description || !targetAmount || !minInvestment ||
        !maxInvestment || !expectedROI || !duration || !dailyRepaymentPercentage ||
        !endDate) {
      return NextResponse.json(
        { message: 'All required fields must be provided' },
        { status: 400 }
      );
    }

    // Validate shop exists
    const shop = await Shop.findById(shopId);
    if (!shop) {
      return NextResponse.json(
        { message: 'Shop not found' },
        { status: 404 }
      );
    }

    // Validate dates
    const end = new Date(endDate);
    const now = new Date();

    // If startDate is provided, validate it; otherwise, use current date as start
    let start: Date;
    if (startDate) {
      start = new Date(startDate);
      if (start <= now) {
        return NextResponse.json(
          { message: 'Start date must be in the future' },
          { status: 400 }
        );
      }
    } else {
      // If no startDate provided, use current date as start
      start = now;
    }

    if (end <= start) {
      return NextResponse.json(
        { message: 'Expected end date must be after start date' },
        { status: 400 }
      );
    }

    // Validate amounts
    if (minInvestment > maxInvestment) {
      return NextResponse.json(
        { message: 'Minimum investment cannot be greater than maximum investment' },
        { status: 400 }
      );
    }

    if (maxInvestment > targetAmount) {
      return NextResponse.json(
        { message: 'Maximum investment cannot be greater than target amount' },
        { status: 400 }
      );
    }

    // Create campaign
    const campaign = new InvestmentCampaign({
      shopId,
      title,
      description,
      targetAmount: Number(targetAmount),
      minInvestment: Number(minInvestment),
      maxInvestment: Number(maxInvestment),
      expectedROI: Number(expectedROI),
      duration: Number(duration),
      dailyRepaymentPercentage: Number(dailyRepaymentPercentage),
      startDate: start,
      endDate: end,
      status: 'draft',
    });

    await campaign.save();

    return NextResponse.json(
      {
        message: 'Campaign created successfully',
        campaign: {
          id: campaign._id,
          title: campaign.title,
          status: campaign.status,
          targetAmount: campaign.targetAmount,
        }
      },
      { status: 201 }
    );
  } catch {
    console.error('Create campaign error');
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}

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

    const campaigns = await InvestmentCampaign.find()
      .populate('shopId', 'name email')
      .sort({ createdAt: -1 });

    return NextResponse.json({ campaigns });
  } catch {
    console.error('Get campaigns error');
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
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

    const { campaignId, status } = await request.json();

    // Validate required fields
    if (!campaignId || !status) {
      return NextResponse.json(
        { message: 'Campaign ID and status are required' },
        { status: 400 }
      );
    }

    // Validate status
    const validStatuses = ['draft', 'active', 'funded', 'repaying', 'completed', 'defaulted'];
    if (!validStatuses.includes(status)) {
      return NextResponse.json(
        { message: 'Invalid status' },
        { status: 400 }
      );
    }

    // Find and update campaign
    const campaign = await InvestmentCampaign.findByIdAndUpdate(
      campaignId,
      { status },
      { new: true }
    ).populate('shopId', 'name email');

    if (!campaign) {
      return NextResponse.json(
        { message: 'Campaign not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      message: 'Campaign status updated successfully',
      campaign: {
        id: campaign._id,
        title: campaign.title,
        status: campaign.status,
        targetAmount: campaign.targetAmount,
      }
    });
  } catch {
    console.error('Update campaign status error');
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 }
    );
  }
}
