import { NextRequest, NextResponse } from 'next/server';
import InvestmentCampaign from '@/models/InvestmentCampaign';
import dbConnect from '@/lib/db';

// Import Shop model to ensure it's registered
import '@/models/shop';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    const campaigns = await InvestmentCampaign.find({ status: 'active' })
      .populate('shopId', 'name email location owner verified totalRaised activeCampaigns')
      .sort({ createdAt: -1 })
      .limit(50);

    return NextResponse.json({
      campaigns,
      success: true,
    });
  } catch (error) {
    console.error('Get investor campaigns error:', error);
    return NextResponse.json(
      {
        message: 'Internal server error',
        success: false,
      },
      { status: 500 }
    );
  }
}
