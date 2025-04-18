// controllers/matchController.js
import User from '../models/User.js';
import Match from '../models/Match.js';

export const addFavoriteMatch = async (req, res) => {
  const { matchIdFromAPI, homeTeam, awayTeam, matchDate } = req.body;

  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(400).json({ message: 'User not found' });

    // Kiểm tra xem trận này đã có trong DB chưa
    let match = await Match.findOne({ matchIdFromAPI });

    if (!match) {
      // Nếu chưa, thêm vào DB
      match = new Match({ matchIdFromAPI, homeTeam, awayTeam, matchDate });
      await match.save();
    }

    // Kiểm tra xem đã có trong favorite chưa
    const alreadyExists = user.favoriteMatches.includes(match._id);
    if (alreadyExists) {
      return res.status(200).json({ message: 'Already in favorites' });
    }

    user.favoriteMatches.push(match._id);
    await user.save();

    res.status(200).json({ message: 'Added to favorites successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

export const getFavoriteMatches = async (req, res) => {
    try {
      const user = await User.findById(req.userId).populate('favoriteMatches');
      if (!user) return res.status(400).json({ message: 'User not found' });
  
      res.status(200).json({ favoriteMatches: user.favoriteMatches });
    } catch (err) {
      res.status(500).json({ message: 'Server error' });
    }
  };