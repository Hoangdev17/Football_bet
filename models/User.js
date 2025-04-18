import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  favoriteMatches: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Match' }],
});

const User = mongoose.model('User', userSchema);

// Sử dụng export default
export default User;
