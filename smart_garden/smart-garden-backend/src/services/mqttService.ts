import mqtt from 'mqtt';
import dotenv from 'dotenv';
import db from '../config/database';

dotenv.config();

class MqttService {
  private client: mqtt.MqttClient | null = null;
  private publishInterval: NodeJS.Timeout | null = null;

  async connect() {
    const broker = process.env.MQTT_BROKER || 'localhost';
    const port = process.env.MQTT_PORT || '1883';
    const brokerUrl = `mqtt://${broker}:${port}`;

    console.log('📡 MQTT Service ativo');
    console.log(`🔌 MQTT Backend: Conectando ao broker ${brokerUrl}`);

    this.client = mqtt.connect(brokerUrl);

    this.client.on('connect', () => {
      console.log('✅ MQTT Backend: Conectado ao broker com sucesso!');
      
      // Subscrever ao tópico de requests
      this.client?.subscribe('smart_garden/request', (err) => {
        if (!err) {
          console.log('📥 MQTT Backend: Inscrito em smart_garden/request');
        }
      });

      // Publicar dados a cada 5 segundos
      this.startPeriodicPublish();
    });

    this.client.on('error', (error) => {
      console.error('🔴 MQTT Backend: Erro de conexão:', error.message);
    });

    this.client.on('message', async (topic, message) => {
      console.log(`📨 MQTT Backend: Mensagem recebida em ${topic}: ${message.toString()}`);
      
      if (topic === 'smart_garden/request' && message.toString() === 'GET_CURRENT') {
        await this.publishCurrentData();
      }
    });
  }

  private startPeriodicPublish() {
    console.log('⏰ MQTT Backend: Publicação periódica iniciada (5s)');
    
    this.publishInterval = setInterval(async () => {
      await this.publishCurrentData();
    }, 5000);
  }

  private async publishCurrentData() {
    try {
      console.log('🔍 MQTT Backend: Buscando dados mais recentes da BD...');
      
      const result = await db.query(
        'SELECT * FROM dados_sensores ORDER BY data_registo DESC LIMIT 1'
      );

      if (result.rows.length > 0) {
        const data = result.rows[0];
        const payload = JSON.stringify({
          temperatura_ar: data.temperatura_ar,
          humidade_ar: data.humidade_ar,
          nivel_agua: data.nivel_agua,
          umidade_solo: data.umidade_solo,
          nivel_luz: data.nivel_luz,
          data_registo: data.data_registo
        });

        this.client?.publish('smart_garden/sensors', payload);
        console.log('📤 MQTT Backend: Dados publicados com sucesso');
      }
    } catch (error) {
      console.error('🔴 MQTT Backend: Erro ao buscar/publicar dados:', error);
    }
  }

  disconnect() {
    if (this.publishInterval) {
      clearInterval(this.publishInterval);
    }
    this.client?.end();
    console.log('🔌 MQTT Backend: Desconectado');
  }
}

export default new MqttService();