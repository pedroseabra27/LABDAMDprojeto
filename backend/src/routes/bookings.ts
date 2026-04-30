import { Router } from "express";
import { eq } from "drizzle-orm";
import { z } from "zod";
import { db } from "../db";
import { agendamentos } from "../db/schema";
import { publishEvent } from "../redis/pubsub";

const router = Router();

const createAgendamentoSchema = z.object({
  quadraId: z.coerce.number().int().positive(),
  clienteId: z.coerce.number().int().positive(),
  prestadorId: z.coerce.number().int().positive().optional().nullable(),
  horarioInicio: z.coerce.date()
});

const statusSchema = z.object({
  status: z.enum(["solicitado", "confirmado", "recusado", "concluido"])
});

function zodErrorResponse(error: z.ZodError) {
  return {
    error: "validation_error",
    details: error.errors.map((issue) => ({
      path: issue.path.join("."),
      message: issue.message
    }))
  };
}

router.post("/", async (req, res) => {
  const parsed = createAgendamentoSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  const { quadraId, clienteId, prestadorId, horarioInicio } = parsed.data;

  const [created] = await db
    .insert(agendamentos)
    .values({
      quadraId,
      clienteId,
      prestadorId: prestadorId ?? null,
      horarioInicio,
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

  return res.status(201).json(created);
});

router.get("/", async (req, res) => {
  const { clienteId, prestadorId, status } = req.query;

  let query = db.select().from(agendamentos);

  if (clienteId) {
    query = query.where(eq(agendamentos.clienteId, Number(clienteId)));
  }

  if (prestadorId) {
    query = query.where(eq(agendamentos.prestadorId, Number(prestadorId)));
  }

  if (status) {
    query = query.where(eq(agendamentos.status, String(status)));
  }

  const list = await query;
  return res.json(list);
});

router.get("/:id", async (req, res) => {
  const id = Number(req.params.id);
  const [found] = await db.select().from(agendamentos).where(eq(agendamentos.id, id));

  if (!found) {
    return res.status(404).json({ error: "booking not found" });
  }

  return res.json(found);
});

router.patch("/:id/status", async (req, res) => {
  const id = Number(req.params.id);
  const parsed = statusSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  const { status } = parsed.data;

  const [updated] = await db
    .update(agendamentos)
    .set({ status: String(status) })
    .where(eq(agendamentos.id, id))
    .returning();

  if (!updated) {
    return res.status(404).json({ error: "booking not found" });
  }

  await publishEvent("agendamento.status_alterado", {
    agendamentoId: updated.id,
    status: updated.status
  });

  return res.json(updated);
});

export default router;
