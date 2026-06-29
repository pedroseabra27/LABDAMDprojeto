import type { Request, Response } from "express";
import { z } from "zod";
import { createCourt, deleteCourtById, getCourtById, listCourts } from "../services/courtService";

const createCourtSchema = z.object({
  nome: z.string().min(1),
  esporte: z.string().min(1),
  precoHora: z.string().regex(/^\d+(\.\d{1,2})?$/, "precoHora deve ser um valor decimal (ex: 100.00)"),
  prestadorId: z.coerce.number().int().positive().optional().nullable()
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

export async function createCourtHandler(req: Request, res: Response) {
  const parsed = createCourtSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  try {
    const created = await createCourt(parsed.data);
    return res.status(201).json(created);
  } catch (error) {
    return res.status(500).json({ error: "failed to create court" });
  }
}

export async function listCourtsHandler(_req: Request, res: Response) {
  try {
    const list = await listCourts();
    return res.json(list);
  } catch (error) {
    return res.status(500).json({ error: "failed to list courts" });
  }
}

export async function getCourtByIdHandler(req: Request, res: Response) {
  const id = Number(req.params.id);

  try {
    const found = await getCourtById(id);

    if (!found) {
      return res.status(404).json({ error: "court not found" });
    }

    return res.json(found);
  } catch (error) {
    return res.status(500).json({ error: "failed to load court" });
  }
}

export async function deleteCourtHandler(req: Request, res: Response) {
  const id = Number(req.params.id);

  try {
    const deleted = await deleteCourtById(id);

    if (!deleted) {
      return res.status(404).json({ error: "court not found" });
    }

    return res.json({ quadraId: deleted.id, status: "deletado" });
  } catch (error) {
    return res.status(500).json({ error: "failed to delete court" });
  }
}
