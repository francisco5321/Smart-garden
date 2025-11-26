import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import gardenRoutes from './routes/gardenRoutes';
import mqttService from './services/mqttService';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/garden', gardenRoutes);

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  
  // Iniciar MQTT
  mqttService.connect();
});

process.on('SIGINT', () => {
  mqttService.disconnect();
  process.exit();
});