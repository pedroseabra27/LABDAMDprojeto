import { Server as SocketIOServer } from "socket.io";
import type { Server } from "node:http";

let io: SocketIOServer;

export function initSocket(server: Server) {
  io = new SocketIOServer(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST", "PATCH"]
    }
  });

  io.on("connection", (socket) => {
    console.log(`[socket] Cliente conectado: ${socket.id}`);

    socket.on("subscribe_cliente", (clienteId) => {
      socket.join(`cliente_${clienteId}`);
      console.log(`[socket] Cliente ${socket.id} entrou na sala: cliente_${clienteId}`);
    });

    socket.on("disconnect", () => {
      console.log(`[socket] Cliente desconectado: ${socket.id}`);
    });
  });

  return io;
}

export function emitBookingUpdate(clienteId: number, booking: any) {
  if (!io) return;
  io.to(`cliente_${clienteId}`).emit("booking_updated", booking);

  io.emit("booking_updated_global", booking);
}
