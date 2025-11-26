import pool from '../config/database';
import { SensorData } from '../models/gardenModel';

class GardenService {
    async getCurrentSensorData(): Promise<SensorData> {
        const result = await pool.query(
            'SELECT * FROM sensor_readings ORDER BY timestamp DESC LIMIT 1'
        );
        
        if (result.rows.length === 0) {
            throw new Error('Nenhum dado disponível');
        }
        
        return result.rows[0];
    }

    async getHistoricalData(limit: number = 100, offset: number = 0): Promise<SensorData[]> {
        const result = await pool.query(
            'SELECT * FROM sensor_readings ORDER BY timestamp DESC LIMIT $1 OFFSET $2',
            [limit, offset]
        );
        return result.rows;
    }

    async createSensorReading(data: Omit<SensorData, 'id' | 'timestamp'>): Promise<SensorData> {
        const result = await pool.query(
            `INSERT INTO sensor_readings 
             (temperature, soil_humidity, air_humidity, water_level, system_operational) 
             VALUES ($1, $2, $3, $4, $5) 
             RETURNING *`,
            [data.temperature, data.soil_humidity, data.air_humidity, data.water_level, data.system_operational]
        );
        return result.rows[0];
    }

    async getLatestReading(): Promise<SensorData | null> {
        const result = await pool.query(
            'SELECT * FROM sensor_readings ORDER BY timestamp DESC LIMIT 1'
        );
        return result.rows[0] || null;
    }
}

export default new GardenService();