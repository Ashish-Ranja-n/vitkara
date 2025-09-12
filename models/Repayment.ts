import mongoose, { Schema, Document } from 'mongoose';

export interface IDistributionDetail {
  investorId: mongoose.Types.ObjectId;
  amount: number;
  distributedAt?: Date;
}

export interface IRepayment extends Document {
  campaignId: mongoose.Types.ObjectId;
  revenueAmount: number; // Shop's total revenue for the day
  repaymentPercentage: number; // % of revenue being repaid
  amount: number; // Calculated repayment amount (revenueAmount * repaymentPercentage / 100)
  repaymentDate: Date;
  reportedBy: mongoose.Types.ObjectId; // Admin who reported
  status: 'pending' | 'distributed' | 'failed';
  distributionDetails: IDistributionDetail[];
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const DistributionDetailSchema = new Schema({
  investorId: {
    type: Schema.Types.ObjectId,
    ref: 'Investor',
    required: true,
  },
  amount: {
    type: Number,
    required: true,
    min: 0,
  },
  distributedAt: {
    type: Date,
  },
}, { _id: false });

const RepaymentSchema: Schema = new Schema({
  campaignId: {
    type: Schema.Types.ObjectId,
    ref: 'InvestmentCampaign',
    required: true,
  },
  revenueAmount: {
    type: Number,
    required: true,
    min: 0,
  },
  repaymentPercentage: {
    type: Number,
    required: true,
    min: 0,
    max: 100,
  },
  amount: {
    type: Number,
    required: true,
    min: 0,
  },
  repaymentDate: {
    type: Date,
    required: true,
  },
  reportedBy: {
    type: Schema.Types.ObjectId,
    ref: 'Admin',
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'distributed', 'failed'],
    default: 'pending',
  },
  distributionDetails: [DistributionDetailSchema],
  notes: {
    type: String,
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
RepaymentSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

// Index for efficient queries
RepaymentSchema.index({ campaignId: 1, repaymentDate: -1 });
RepaymentSchema.index({ status: 1, repaymentDate: -1 });

export default mongoose.models.Repayment || mongoose.model<IRepayment>('Repayment', RepaymentSchema);
