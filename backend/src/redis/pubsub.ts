import "dotenv/config";
import { createClient } from "redis";

const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";

let publisher: ReturnType<typeof createClient> | null = null;
let subscriber: ReturnType<typeof createClient> | null = null;

export async function getPublisher() {
  if (!publisher) {
    publisher = createClient({ url: redisUrl });
    publisher.on("error", (err) => console.error("Redis publisher error", err));
    await publisher.connect();
  }
  return publisher;
}

export async function initRedisSubscriber() {
  if (!subscriber) {
    subscriber = createClient({ url: redisUrl });
    subscriber.on("error", (err) => console.error("Redis subscriber error", err));
    await subscriber.connect();

    await subscriber.subscribe("agendamento.criado", (message) => {
      console.log("[event] agendamento.criado", message);
    });

    await subscriber.subscribe("agendamento.status_alterado", (message) => {
      console.log("[event] agendamento.status_alterado", message);
    });
  }
}

export async function publishEvent(channel: string, payload: unknown) {
  const pub = await getPublisher();
  await pub.publish(channel, JSON.stringify(payload));
}
