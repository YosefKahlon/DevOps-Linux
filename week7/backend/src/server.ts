import app from './app';
import dotenv from 'dotenv';
import { initializeDatabase } from './config/db';

dotenv.config();

const PORT = process.env.PORT || 3000;

async function startServerWithDbRetry(retries = 10, delayMs = 2000) {
  for (let i = 0; i < retries; i++) {
    try {
      await initializeDatabase();
      console.log('Database initialized.');
      app.listen(PORT, () => {
        console.log(`Server running on http://localhost:${PORT}`);
      });
      return;
    } catch (err) {
      if (err instanceof Error) {
        console.error(`Database initialization failed (attempt ${i + 1}/${retries}):`, err.message);
      } else {
        console.error(`Database initialization failed (attempt ${i + 1}/${retries}):`, err);
      }
      if (i < retries - 1) {
        await new Promise(res => setTimeout(res, delayMs));
      } else {
        process.exit(1);
      }
    }
  }
}

startServerWithDbRetry();
