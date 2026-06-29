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
    console.log(`[socket] Conectado: ${socket.id}`);

    // Cliente se inscreve para receber atualizações dos seus agendamentos
    socket.on("subscribe_cliente", (clienteId) => {
      socket.join(`cliente_${clienteId}`);
      console.log(`[socket] ${socket.id} entrou na sala: cliente_${clienteId}`);
    });

    // Prestador se inscreve para receber novos agendamentos das suas quadras
    socket.on("subscribe_prestador", (prestadorId) => {
      socket.join(`prestador_${prestadorId}`);
      console.log(`[socket] ${socket.id} entrou na sala: prestador_${prestadorId}`);
    });

    socket.on("disconnect", () => {
      console.log(`[socket] Desconectado: ${socket.id}`);
    });
  });

  return io;
}

// Notifica o CLIENTE quando o status do agendamento dele muda
export function emitBookingUpdate(clienteId: number, booking: any) {
  if (!io) return;
  io.to(`cliente_${clienteId}`).emit("booking_updated", booking);
  console.log(`[socket] Emitiu booking_updated para cliente_${clienteId}`);
}

// Notifica o PRESTADOR quando um novo agendamento é criado nas quadras dele
export function emitNewBookingToPrestador(prestadorId: number, booking: any) {
  if (!io) return;
  io.to(`prestador_${prestadorId}`).emit("new_booking", booking);
  console.log(`[socket] Emitiu new_booking para prestador_${prestadorId}`);
}
