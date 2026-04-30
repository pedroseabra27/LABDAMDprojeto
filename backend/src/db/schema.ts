import { pgTable, serial, integer, timestamp, varchar } from "drizzle-orm/pg-core";

export const agendamentos = pgTable("agendamentos", {
  id: serial("id").primaryKey(),
  quadraId: integer("quadra_id").notNull(),
  clienteId: integer("cliente_id").notNull(),
  prestadorId: integer("prestador_id"),
  horarioInicio: timestamp("horario_inicio").notNull(),
  status: varchar("status", { length: 32 }).notNull()
});

export type AgendamentoInsert = typeof agendamentos.$inferInsert;
export type AgendamentoSelect = typeof agendamentos.$inferSelect;
