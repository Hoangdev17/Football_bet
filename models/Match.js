// models/Match.js
import mongoose from 'mongoose';

const matchSchema = new mongoose.Schema({
  matchIdFromAPI: { type: String, required: true, unique: true },
  homeTeam: { type: String, required: true },
  awayTeam: { type: String, required: true },
  matchDate: { type: Date, required: true },
});

const Match = mongoose.model('Match', matchSchema);
export default Match;

