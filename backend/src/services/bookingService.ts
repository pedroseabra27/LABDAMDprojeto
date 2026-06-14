import { eq } from "drizzle-orm";
import { db } from "../db";
import { agendamentos, type AgendamentoSelect } from "../db/schema";
import { publishEvent } from "../rabbitmq/publisher";
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

  await publishEvent("agendamento.criado", {
    agendamentoId: created.id,
    quadraId: created.quadraId,
    clienteId: created.clienteId,
    prestadorId: created.prestadorId,
    horarioInicio: created.horarioInicio,
    status: created.status
  });

  return created;
}

export async function listBookings(filters: ListBookingsFilters): Promise<AgendamentoSelect[]> {
  let query = db.select().from(agendamentos);

  if (filters.clienteId !== undefined) {
    query = query.where(eq(agendamentos.clienteId, filters.clienteId));
  }

  if (filters.prestadorId !== undefined) {
    query = query.where(eq(agendamentos.prestadorId, filters.prestadorId));
  }

  if (filters.status !== undefined) {
    query = query.where(eq(agendamentos.status, filters.status));
  }

  return query;
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

  await publishEvent("agendamento.deletado", {
    agendamentoId: deleted.id,
    status: "deletado"
  });

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

  await publishEvent("agendamento.status_alterado", {
    agendamentoId: updated.id,
    status: updated.status
  });

  emitBookingUpdate(updated.clienteId, updated);

  return updated;
}
