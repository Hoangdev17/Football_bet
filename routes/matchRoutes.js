import express from 'express';
import jwt from 'jsonwebtoken';
import { addFavoriteMatch, getFavoriteMatches } from '../controllers/matchController.js';  

const router = express.Router();

// Middleware kiểm tra JWT
const authenticate = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(403).json({ message: 'No token provided' });
  }

  jwt.verify(token, 'your_jwt_secret', (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Invalid token' });
    }
    req.userId = decoded.userId;
    next();
  });
};

// Thêm trận đấu vào yêu thích
router.post('/favorite', authenticate, addFavoriteMatch);
router.get('/favorites', authenticate, getFavoriteMatches);

export default router;  
