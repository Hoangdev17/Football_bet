import express from 'express';
import { register, login } from '../controllers/authController.js'; 
const router = express.Router();

// Đăng ký người dùng
router.post('/register', register);

// Đăng nhập người dùng
router.post('/login', login);

export default router;  
