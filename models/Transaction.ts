import mongoose, { Schema, Document } from 'mongoose';

export interface ITransaction extends Document {
  type: 'investment' | 'repayment' | 'withdrawal' | 'deposit' | 'refund';
  amount: number;
  fromUser: mongoose.Types.ObjectId; // Investor or Shop
  toUser?: mongoose.Types.ObjectId;
  campaignId?: mongoose.Types.ObjectId;
  investmentId?: mongoose.Types.ObjectId;
  repaymentId?: mongoose.Types.ObjectId;
  description: string;
  status: 'pending' | 'completed' | 'failed' | 'cancelled';
  transactionDate: Date;
  referenceId?: string; // External payment reference
  metadata?: Record<string, any>; // Additional data
  createdAt: Date;
  updatedAt: Date;
}

const TransactionSchema: Schema = new Schema({
  type: {
    type: String,
    enum: ['investment', 'repayment', 'withdrawal', 'deposit', 'refund'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
    min: 0,
  },
  fromUser: {
    type: Schema.Types.ObjectId,
    required: true,
    refPath: 'fromUserModel',
  },
  fromUserModel: {
    type: String,
    required: true,
    enum: ['Investor', 'Shop'],
  },
  toUser: {
    type: Schema.Types.ObjectId,
    refPath: 'toUserModel',
  },
  toUserModel: {
    type: String,
    enum: ['Investor', 'Shop', 'Admin'],
  },
  campaignId: {
    type: Schema.Types.ObjectId,
    ref: 'InvestmentCampaign',
  },
  investmentId: {
    type: Schema.Types.ObjectId,
    ref: 'Investment',
  },
  repaymentId: {
    type: Schema.Types.ObjectId,
    ref: 'Repayment',
  },
  description: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'pending',
  },
  transactionDate: {
    type: Date,
    default: Date.now,
  },
  referenceId: {
    type: String,
  },
  metadata: {
    type: Schema.Types.Mixed,
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
TransactionSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

// Indexes for efficient queries
TransactionSchema.index({ fromUser: 1, transactionDate: -1 });
TransactionSchema.index({ toUser: 1, transactionDate: -1 });
TransactionSchema.index({ campaignId: 1, transactionDate: -1 });
TransactionSchema.index({ type: 1, status: 1, transactionDate: -1 });
TransactionSchema.index({ referenceId: 1 }, { unique: true, sparse: true });

export default mongoose.models.Transaction || mongoose.model<ITransaction>('Transaction', TransactionSchema);
