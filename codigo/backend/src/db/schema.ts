import { pgTable, serial, integer, timestamp, varchar, decimal } from "drizzle-orm/pg-core";

export const usuarios = pgTable("usuarios", {
  id: serial("id").primaryKey(),
  nome: varchar("nome", { length: 255 }).notNull(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  senha: varchar("senha", { length: 255 }).notNull(),
  tipo: varchar("tipo", { length: 32 }).notNull()
});

export const quadras = pgTable("quadras", {
  id: serial("id").primaryKey(),
  nome: varchar("nome", { length: 255 }).notNull(),
  esporte: varchar("esporte", { length: 128 }).notNull(),
  precoHora: decimal("preco_hora", { precision: 10, scale: 2 }).notNull(),
  prestadorId: integer("prestador_id").references(() => usuarios.id),
  imagemUrl: varchar("imagem_url", { length: 1024 }),
  endereco: varchar("endereco", { length: 512 }),
  descricao: varchar("descricao", { length: 2048 })
});

export const agendamentos = pgTable("agendamentos", {
  id: serial("id").primaryKey(),
  quadraId: integer("quadra_id").references(() => quadras.id).notNull(),
  clienteId: integer("cliente_id").references(() => usuarios.id).notNull(),
  prestadorId: integer("prestador_id").references(() => usuarios.id),
  horarioInicio: timestamp("horario_inicio").notNull(),
  status: varchar("status", { length: 32 }).notNull(),
  nota: integer("nota"),
  comentarioAvaliacao: varchar("comentario_avaliacao", { length: 1024 })
});

export type UsuarioInsert = typeof usuarios.$inferInsert;
export type UsuarioSelect = typeof usuarios.$inferSelect;

export type QuadraInsert = typeof quadras.$inferInsert;
export type QuadraSelect = typeof quadras.$inferSelect;

export type AgendamentoInsert = typeof agendamentos.$inferInsert;
export type AgendamentoSelect = typeof agendamentos.$inferSelect;

