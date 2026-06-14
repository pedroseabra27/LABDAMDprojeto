import { Server as SocketIOServer } from "socket.io";
import type { Server } from "node:http";

let io: SocketIOServer;

export function initSocket(server: Server) {
  io = new SocketIOServer(server, {
    cors: {
      origin: "*", // Permite conexão do App Flutter
      methods: ["GET", "POST", "PATCH"]
    }
  });

  io.on("connection", (socket) => {
    console.log(`[socket] Cliente conectado: ${socket.id}`);

    // Cliente pode se inscrever no próprio ID para receber apenas seus agendamentos
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
  // Emite evento apenas para o cliente específico
  io.to(`cliente_${clienteId}`).emit("booking_updated", booking);
  
  // Emite para todos também (para facilitar testes)
  io.emit("booking_updated_global", booking);
}
