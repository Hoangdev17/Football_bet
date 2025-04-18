import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

export const register = async (req, res) => {

    const { username, email, password } = req.body;

    try {
        // Kiểm tra người dùng đã tồn tại chưa
        const userExists = await User.findOne({ email });
        if (userExists) {
        return res.status(400).json({ message: 'User already exists' });
        }

        // Mã hóa mật khẩu
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ username, email, password: hashedPassword });

        await newUser.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }

}

export const login = async (req, res) => {
    const { email, password } = req.body;

    try {
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(400).json({ message: 'Invalid credentials' });
      }
  
      // So sánh mật khẩu
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ message: 'Invalid credentials' });
      }
  
      // Tạo JWT
      const token = jwt.sign({ userId: user._id }, 'your_jwt_secret', {
        expiresIn: '1h',
      });
  
      res.json({ token });
    } catch (err) {
      res.status(500).json({ message: 'Server error' });
    }
}      