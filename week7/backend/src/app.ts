import express from 'express';
import cors from 'cors';
import userRoutes from './routes/user.routes';

const app = express();
app.use(express.json());
app.use(cors());

// Health check endpoint
app.get('/health', (req, res) => {
    console.log('Health check endpoint hit');
  res.status(200).json({ status: 'UP' });
});

// app.use('/api/users', userRoutes);

export default app;
