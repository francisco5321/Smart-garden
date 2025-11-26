import { Request, Response } from 'express';
import gardenService from '../services/gardenService';

class GardenController {
    async getSensorData(req: Request, res: Response): Promise<void> {
        try {
            const data = await gardenService.getCurrentSensorData();
            res.status(200).json(data);
        } catch (error) {
            console.error('Error fetching sensor data:', error);
            res.status(500).json({ 
                error: 'Erro ao buscar dados dos sensores',
                message: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    async getHistoricalData(req: Request, res: Response): Promise<void> {
        try {
            const { limit = 100, offset = 0 } = req.query;
            const data = await gardenService.getHistoricalData(
                Number(limit),
                Number(offset)
            );
            res.status(200).json(data);
        } catch (error) {
            console.error('Error fetching historical data:', error);
            res.status(500).json({ 
                error: 'Erro ao buscar histórico',
                message: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    async createSensorReading(req: Request, res: Response): Promise<void> {
        try {
            const { temperature, soil_humidity, air_humidity, water_level, system_operational } = req.body;
            
            if (temperature === undefined || soil_humidity === undefined || 
                air_humidity === undefined || water_level === undefined) {
                res.status(400).json({ error: 'Dados incompletos' });
                return;
            }

            const newReading = await gardenService.createSensorReading({
                temperature,
                soil_humidity,
                air_humidity,
                water_level,
                system_operational: system_operational ?? true
            });
            
            res.status(201).json(newReading);
        } catch (error) {
            console.error('Error creating sensor reading:', error);
            res.status(500).json({ 
                error: 'Erro ao criar leitura',
                message: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    async getLatestReading(req: Request, res: Response): Promise<void> {
        try {
            const data = await gardenService.getLatestReading();
            if (!data) {
                res.status(404).json({ error: 'Nenhuma leitura encontrada' });
                return;
            }
            res.status(200).json(data);
        } catch (error) {
            console.error('Error fetching latest reading:', error);
            res.status(500).json({ 
                error: 'Erro ao buscar última leitura',
                message: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}

export default new GardenController();