import express, { Application } from 'express';
const cors = require('cors');
const dotenv = require('dotenv');
import apiRoutes from './routes/api';

dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', apiRoutes);

// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', message: 'Smart Garden API is running' });
});

// Start server
app.listen(PORT, () => {
    console.log(`🌱 Server running on http://localhost:${PORT}`);
});

export default app;