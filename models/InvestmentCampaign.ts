import mongoose, { Schema, Document } from 'mongoose';

export interface IInvestmentCampaign extends Document {
  shopId: mongoose.Types.ObjectId;
  title: string;
  description: string;
  targetAmount: number;
  currentAmount: number;
  minInvestment: number;
  maxInvestment: number;
  expectedROI: number;
  duration: number; // in days
  dailyRepaymentPercentage: number; // % of daily revenue to repay
  status: 'draft' | 'active' | 'funded' | 'repaying' | 'completed' | 'defaulted';
  startDate?: Date;
  endDate: Date;
  repaymentStartDate?: Date;
  totalRepaid: number;
  createdAt: Date;
  updatedAt: Date;
}

const InvestmentCampaignSchema: Schema = new Schema({
  shopId: {
    type: Schema.Types.ObjectId,
    ref: 'Shop',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  targetAmount: {
    type: Number,
    required: true,
    min: 0,
  },
  currentAmount: {
    type: Number,
    default: 0,
    min: 0,
  },
  minInvestment: {
    type: Number,
    required: true,
    min: 1,
  },
  maxInvestment: {
    type: Number,
    required: true,
    min: 1,
  },
  expectedROI: {
    type: Number,
    required: true,
    min: 0,
  },
  duration: {
    type: Number,
    required: true,
    min: 1,
  },
  dailyRepaymentPercentage: {
    type: Number,
    required: true,
    min: 0,
    max: 100,
  },
  status: {
    type: String,
    enum: ['draft', 'active', 'funded', 'repaying', 'completed', 'defaulted'],
    default: 'draft',
  },
  startDate: {
    type: Date,
    default: Date.now,
  },
  endDate: {
    type: Date,
    required: true,
  },
  repaymentStartDate: {
    type: Date,
  },
  totalRepaid: {
    type: Number,
    default: 0,
    min: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Update the updatedAt field on save
InvestmentCampaignSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

export default mongoose.models.InvestmentCampaign || mongoose.model<IInvestmentCampaign>('InvestmentCampaign', InvestmentCampaignSchema);
