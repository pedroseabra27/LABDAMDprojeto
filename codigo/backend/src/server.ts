import "dotenv/config";
import http from "node:http";
import { createApp } from "./app";
import { initSocket } from "./socket";

const port = Number(process.env.PORT || 3000);

const app = createApp();
const server = http.createServer(app);

// Inicializa o WebSocket
initSocket(server);

server.listen(port, () => {
  console.log(`Server HTTP/WebSocket running on port ${port}`);
});
