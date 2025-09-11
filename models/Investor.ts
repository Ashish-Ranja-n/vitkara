import mongoose, { Schema, Document } from 'mongoose';

export interface IInvestor extends Document {
  name: string;
  email: string;
  googleId?: string;
  avatar?: string;
  age?: number;
  location?: string;
  verified: boolean;
  totalInvestment: number;
  walletBalance: number;
  defaultDashboard: string;
  createdAt: Date;
}

const InvestorSchema: Schema = new Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  googleId: {
    type: String,
    unique: true,
    sparse: true,
  },
  avatar: {
    type: String,
  },
  age: {
    type: Number,
  },
  location: {
    type: String,
  },
  verified: {
    type: Boolean,
    default: false,
  },
  totalInvestment: {
    type: Number,
    default: 0,
  },
  walletBalance: {
    type: Number,
    default: 0,
  },
  defaultDashboard: {
    type: String,
    default: 'Open Market',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

export default mongoose.models.Investor || mongoose.model<IInvestor>('Investor', InvestorSchema);
