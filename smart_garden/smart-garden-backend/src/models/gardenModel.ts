import { Schema, model } from 'mongoose';

const gardenSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    location: {
        type: String,
        required: true,
    },
    size: {
        type: Number,
        required: true,
    },
    plants: [{
        type: String,
    }],
    createdAt: {
        type: Date,
        default: Date.now,
    },
    updatedAt: {
        type: Date,
        default: Date.now,
    },
});

const Garden = model('Garden', gardenSchema);

export default Garden;

export interface SensorData {
    id?: number;
    temperature: number;
    soil_humidity: number;
    air_humidity: number;
    water_level: number;
    system_operational: boolean;
    timestamp?: Date;
}