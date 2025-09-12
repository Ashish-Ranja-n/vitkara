import { NextRequest, NextResponse } from 'next/server';
import InvestmentCampaign from '@/models/InvestmentCampaign';
import dbConnect from '@/lib/db';

// Import Shop model to ensure it's registered
import '@/models/shop';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    const { searchParams } = new URL(request.url);
    const includeAll = searchParams.get('includeAll') === 'true';

    let query = {};
    if (!includeAll) {
      // Default behavior: only active campaigns for "All Listings"
      query = { status: 'active' };
    }
    // If includeAll=true, fetch all campaigns regardless of status

    const campaigns = await InvestmentCampaign.find(query)
      .populate('shopId', 'name email location owner verified totalRaised activeCampaigns avgUpiTransactions')
      .sort({ createdAt: -1 })
      .limit(includeAll ? 200 : 50); // Allow more campaigns when fetching all

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
