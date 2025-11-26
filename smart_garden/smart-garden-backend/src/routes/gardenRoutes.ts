import { Router } from 'express';
import gardenService from '../services/gardenService';

const router = Router();

// Obter dados atuais dos sensores
router.get('/sensor/current', async (req, res) => {
    try {
        const data = await gardenService.getCurrentSensorData();
        res.json(data);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao obter dados', error });
    }
});

// Obter histórico de dados
router.get('/sensor/history', async (req, res) => {
    try {
        const limit = parseInt(req.query.limit as string) || 100;
        const offset = parseInt(req.query.offset as string) || 0;
        const data = await gardenService.getHistoricalData(limit, offset);
        res.json(data);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao obter histórico', error });
    }
});

// Criar nova leitura
router.post('/sensor', async (req, res) => {
    try {
        const data = await gardenService.createSensorReading(req.body);
        res.status(201).json(data);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao criar leitura', error });
    }
});

export default router;