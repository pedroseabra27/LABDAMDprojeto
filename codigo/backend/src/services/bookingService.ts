import { eq, and } from "drizzle-orm";
import { db } from "../db";
import { agendamentos, quadras, type AgendamentoSelect } from "../db/schema";
import { emitBookingUpdate, emitNewBookingToPrestador } from "../socket";

export type BookingStatus = "solicitado" | "confirmado" | "recusado" | "concluido";

export type CreateBookingInput = {
  quadraId: number;
  clienteId: number;
  prestadorId?: number | null;
  horarioInicio: Date;
};

export type ListBookingsFilters = {
  clienteId?: number;
  prestadorId?: number;
  status?: BookingStatus;
};

export async function createBooking(input: CreateBookingInput): Promise<AgendamentoSelect> {
  // Busca a quadra para descobrir quem é o prestador (dono)
  const [court] = await db.select().from(quadras).where(eq(quadras.id, input.quadraId));
  const prestadorId = court?.prestadorId ?? input.prestadorId ?? null;

  const [created] = await db
    .insert(agendamentos)
    .values({
      quadraId: input.quadraId,
      clienteId: input.clienteId,
      prestadorId: prestadorId,
      horarioInicio: input.horarioInicio,
      status: "solicitado"
    })
    .returning();

  // Notifica o prestador via WebSocket
  if (prestadorId) {
    emitNewBookingToPrestador(prestadorId, created);
  }

  return created;
}

export async function listBookings(filters: ListBookingsFilters): Promise<AgendamentoSelect[]> {
  const conditions = [];

  if (filters.clienteId !== undefined) {
    conditions.push(eq(agendamentos.clienteId, filters.clienteId));
  }

  if (filters.prestadorId !== undefined) {
    conditions.push(eq(agendamentos.prestadorId, filters.prestadorId));
  }

  if (filters.status !== undefined) {
    conditions.push(eq(agendamentos.status, filters.status));
  }

  if (conditions.length === 0) {
    return db.select().from(agendamentos);
  }

  return db.select().from(agendamentos).where(and(...conditions));
}

export async function getBookingById(id: number): Promise<AgendamentoSelect | null> {
  const [found] = await db.select().from(agendamentos).where(eq(agendamentos.id, id));
  return found ?? null;
}

export async function deleteBookingById(id: number): Promise<AgendamentoSelect | null> {
  const [deleted] = await db.delete(agendamentos).where(eq(agendamentos.id, id)).returning();
  if (!deleted) {
    return null;
  }

  emitBookingUpdate(deleted.clienteId, deleted);

  return deleted;
}

export async function updateBookingStatus(
  id: number,
  status: BookingStatus
): Promise<AgendamentoSelect | null> {
  const [updated] = await db
    .update(agendamentos)
    .set({ status })
    .where(eq(agendamentos.id, id))
    .returning();

  if (!updated) {
    return null;
  }

  // Notifica o cliente que o status mudou
  emitBookingUpdate(updated.clienteId, updated);

  return updated;
}

export async function reviewBooking(
  id: number,
  nota: number,
  comentarioAvaliacao?: string
): Promise<AgendamentoSelect | null> {
  const [booking] = await db.select().from(agendamentos).where(eq(agendamentos.id, id));
  
  if (!booking || booking.status !== "concluido") {
    return null; // Apenas agendamentos concluidos podem ser avaliados
  }

  const [updated] = await db
    .update(agendamentos)
    .set({ nota, comentarioAvaliacao })
    .where(eq(agendamentos.id, id))
    .returning();

  emitBookingUpdate(updated.clienteId, updated);
  
  return updated;
}
