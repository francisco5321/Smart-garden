import { Router } from 'express';
import gardenController from '../controllers/gardenController';

const router = Router();

// GET routes
router.get('/sensor-data', gardenController.getSensorData);
router.get('/sensor-data/history', gardenController.getHistoricalData);
router.get('/sensor-data/latest', gardenController.getLatestReading);

// POST routes
router.post('/sensor-data', gardenController.createSensorReading);

export default router;