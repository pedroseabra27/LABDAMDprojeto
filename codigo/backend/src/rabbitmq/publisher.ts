import "dotenv/config";
import amqplib, { type Channel, type Connection } from "amqplib";

const AMQP_URL = process.env.AMQP_URL || "amqp://localhost:5672";
const EXCHANGE = "agendamentos";

let connection: Connection | null = null;
let channel: Channel | null = null;

async function getChannel(): Promise<Channel> {
  if (!channel) {
    connection = await amqplib.connect(AMQP_URL);
    channel = await connection.createChannel();
    await channel.assertExchange(EXCHANGE, "topic", { durable: true });
  }
  return channel;
}

export async function publishEvent(eventName: string, payload: unknown): Promise<void> {
  const ch = await getChannel();
  const message = JSON.stringify(payload);
  ch.publish(EXCHANGE, eventName, Buffer.from(message), { persistent: true });
  console.log(`[publisher] ${eventName}`, payload);
}
