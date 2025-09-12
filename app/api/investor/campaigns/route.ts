import { NextRequest, NextResponse } from 'next/server';
import InvestmentCampaign from '@/models/InvestmentCampaign';
import Shop from '@/models/shop';
import dbConnect from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    // Get query parameters for filtering
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status') || 'active';
    const limit = parseInt(searchParams.get('limit') || '50');
    const page = parseInt(searchParams.get('page') || '1');
    const skip = (page - 1) * limit;

    // Build query - only return active campaigns for investors
    const query: any = {};

    if (status === 'active') {
      query.status = 'active';
      // Also include campaigns that are 'funded' or 'repaying' as they are still visible to investors
      query.status = { $in: ['active', 'funded', 'repaying'] };
    } else if (status !== 'all') {
      query.status = status;
    }

    // Only return campaigns that haven't ended yet
    const now = new Date();
    query.endDate = { $gte: now };

    const campaigns = await InvestmentCampaign.find(query)
      .populate('shopId', 'name email location owner verified totalRaised activeCampaigns')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Get total count for pagination
    const total = await InvestmentCampaign.countDocuments(query);

    return NextResponse.json({
      campaigns,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
      success: true,
    });
  } catch {
    console.error('Get investor campaigns error');
    return NextResponse.json(
      {
        message: 'Internal server error',
        success: false,
      },
      { status: 500 }
    );
  }
}
