import "dotenv/config";
import { createApp } from "./app";
import { initRedisSubscriber } from "./redis/pubsub";

const port = Number(process.env.PORT || 3000);

const app = createApp();

app.listen(port, async () => {
  await initRedisSubscriber();
  console.log(`Server running on port ${port}`);
});
