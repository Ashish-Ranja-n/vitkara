import mongoose, { Schema, Document } from 'mongoose';

export interface IInvestment extends Document {
  investorId: mongoose.Types.ObjectId;
  campaignId: mongoose.Types.ObjectId;
  amount: number;
  shares: number;
  purchaseDate: Date;
  expectedReturns: number;
  totalReceived: number;
  status: 'active' | 'completed' | 'defaulted';
  createdAt: Date;
  updatedAt: Date;
}

const InvestmentSchema: Schema = new Schema({
  investorId: {
    type: Schema.Types.ObjectId,
    ref: 'Investor',
    required: true,
  },
  campaignId: {
    type: Schema.Types.ObjectId,
    ref: 'InvestmentCampaign',
    required: true,
  },
  amount: {
    type: Number,
    required: true,
    min: 0,
  },
  shares: {
    type: Number,
    required: true,
    min: 1,
  },
  purchaseDate: {
    type: Date,
    default: Date.now,
  },
  expectedReturns: {
    type: Number,
    required: true,
    min: 0,
  },
  totalReceived: {
    type: Number,
    default: 0,
    min: 0,
  },
  status: {
    type: String,
    enum: ['active', 'completed', 'defaulted'],
    default: 'active',
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
InvestmentSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

// Compound index for efficient queries
InvestmentSchema.index({ investorId: 1, campaignId: 1 });
InvestmentSchema.index({ campaignId: 1, status: 1 });

export default mongoose.models.Investment || mongoose.model<IInvestment>('Investment', InvestmentSchema);
