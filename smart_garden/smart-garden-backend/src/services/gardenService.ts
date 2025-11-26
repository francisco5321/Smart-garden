import pool from '../config/database';
import { SensorData } from '../models/gardenModel';

class GardenService {
    async getCurrentSensorData(): Promise<SensorData> {
        const result = await pool.query(
            'SELECT * FROM dados_sensores ORDER BY data_registo DESC LIMIT 1'
        );
        
        if (result.rows.length === 0) {
            throw new Error('Nenhum dado disponível');
        }
        
        return result.rows[0];
    }

    async getHistoricalData(limit: number = 100, offset: number = 0): Promise<SensorData[]> {
        const result = await pool.query(
            'SELECT * FROM dados_sensores ORDER BY data_registo DESC LIMIT $1 OFFSET $2',
            [limit, offset]
        );
        return result.rows;
    }

    async createSensorReading(data: Omit<SensorData, 'id' | 'data_registo'>): Promise<SensorData> {
        const result = await pool.query(
            `INSERT INTO dados_sensores 
             (temperatura_ar, humidade_ar, nivel_agua, umidade_solo, nivel_luz) 
             VALUES ($1, $2, $3, $4, $5) 
             RETURNING *`,
            [data.temperatura_ar, data.humidade_ar, data.nivel_agua, data.umidade_solo, data.nivel_luz]
        );
        return result.rows[0];
    }

    async getLatestReading(): Promise<SensorData | null> {
        const result = await pool.query(
            'SELECT * FROM dados_sensores ORDER BY data_registo DESC LIMIT 1'
        );
        return result.rows[0] || null;
    }
}

export default new GardenService();