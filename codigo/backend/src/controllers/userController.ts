import type { Request, Response } from "express";
import { z } from "zod";
import { createUser, deleteUserById, getUserById, listUsers } from "../services/userService";

const createUserSchema = z.object({
  nome: z.string().min(1),
  email: z.string().email(),
  senha: z.string().min(1),
  tipo: z.enum(["cliente", "prestador"])
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

export async function createUserHandler(req: Request, res: Response) {
  const parsed = createUserSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  try {
    const created = await createUser(parsed.data);
    return res.status(201).json(created);
  } catch (error) {
    return res.status(500).json({ error: "failed to create user" });
  }
}

export async function listUsersHandler(_req: Request, res: Response) {
  try {
    const list = await listUsers();
    return res.json(list);
  } catch (error) {
    return res.status(500).json({ error: "failed to list users" });
  }
}

export async function getUserByIdHandler(req: Request, res: Response) {
  const id = Number(req.params.id);

  try {
    const found = await getUserById(id);

    if (!found) {
      return res.status(404).json({ error: "user not found" });
    }

    return res.json(found);
  } catch (error) {
    return res.status(500).json({ error: "failed to load user" });
  }
}

export async function deleteUserHandler(req: Request, res: Response) {
  const id = Number(req.params.id);

  try {
    const deleted = await deleteUserById(id);

    if (!deleted) {
      return res.status(404).json({ error: "user not found" });
    }

    return res.json({ usuarioId: deleted.id, status: "deletado" });
  } catch (error) {
    return res.status(500).json({ error: "failed to delete user" });
  }
}
