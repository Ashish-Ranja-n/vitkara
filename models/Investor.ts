import mongoose, { Schema, Document } from 'mongoose';

export interface IInvestor extends Document {
  name: string;
  email: string;
  googleId?: string;
  avatar?: string;
  age?: number;
  location?: string;
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
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

export default mongoose.models.Investor || mongoose.model<IInvestor>('Investor', InvestorSchema);
