import mongoose, { Schema, Document } from 'mongoose';

export interface IShop extends Document {
  name: string;
  description?: string;
  location?: string;
  owner: string;
  email: string;
  avgUpiTransactions?: number;
  verified: boolean;
  totalRaised: number; // Total amount raised from all campaigns
  activeCampaigns: number; // Number of currently active campaigns
  completedCampaigns: number; // Number of completed campaigns
  repaymentHistory: number; // Total amount repaid
  defaultRate: number; // Default rate percentage
  createdAt: Date;
}

const ShopSchema: Schema = new Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  location: {
    type: String,
  },
  owner: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  avgUpiTransactions: {
    type: Number,
    default: 0,
  },
  verified: {
    type: Boolean,
    default: false,
  },
  totalRaised: {
    type: Number,
    default: 0,
    min: 0,
  },
  activeCampaigns: {
    type: Number,
    default: 0,
    min: 0,
  },
  completedCampaigns: {
    type: Number,
    default: 0,
    min: 0,
  },
  repaymentHistory: {
    type: Number,
    default: 0,
    min: 0,
  },
  defaultRate: {
    type: Number,
    default: 0,
    min: 0,
    max: 100,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

export default mongoose.models.Shop || mongoose.model<IShop>('Shop', ShopSchema);
