import { eq, and } from "drizzle-orm";
import { db } from "../db";
import { agendamentos, type AgendamentoSelect } from "../db/schema";
import { emitBookingUpdate } from "../socket";

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
  const [created] = await db
    .insert(agendamentos)
    .values({
      quadraId: input.quadraId,
      clienteId: input.clienteId,
      prestadorId: input.prestadorId ?? null,
      horarioInicio: input.horarioInicio,
      status: "solicitado"
    })
    .returning();

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

  emitBookingUpdate(updated.clienteId, updated);

  return updated;
}
