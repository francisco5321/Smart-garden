export interface SensorData {
    id: number;
    data_registo: Date;
    temperatura_ar: number;
    humidade_ar: number;
    nivel_agua: number;
    umidade_solo: number;
    nivel_luz: number;
}

export interface Garden {
    id: number;
    name: string;
    location: string;
    size: number;
    plants: string[];
    createdAt: Date;
    updatedAt: Date;
}