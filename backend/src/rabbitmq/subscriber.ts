import "dotenv/config";
import amqplib from "amqplib";

const AMQP_URL = process.env.AMQP_URL || "amqp://localhost:5672";
const EXCHANGE = "agendamentos";

async function startSubscriber() {
  console.log("[subscriber] Conectando ao RabbitMQ...");

  const connection = await amqplib.connect(AMQP_URL);
  const channel = await connection.createChannel();

  await channel.assertExchange(EXCHANGE, "topic", { durable: true });

  const { queue } = await channel.assertQueue("", { exclusive: true });

  await channel.bindQueue(queue, EXCHANGE, "agendamento.*");

  console.log("[subscriber] Aguardando eventos... (Ctrl+C para sair)\n");

  channel.consume(queue, (msg) => {
    if (!msg) return;

    const event = msg.fields.routingKey;
    const payload = JSON.parse(msg.content.toString());

    console.log(`[event] ${event}`);
    console.log(JSON.stringify(payload, null, 2));
    console.log("---");

    channel.ack(msg);
  });
}

startSubscriber().catch((err) => {
  console.error("[subscriber] Erro ao conectar:", err);
  process.exit(1);
});
