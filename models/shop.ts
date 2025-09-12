import mongoose, { Schema, Document } from 'mongoose';

export interface IShop extends Document {
  name: string;
  description?: string;
  location?: string;
  owner: string;
  email: string;
  verified: boolean;
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
  verified: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

export default mongoose.models.Shop || mongoose.model<IShop>('Shop', ShopSchema);
