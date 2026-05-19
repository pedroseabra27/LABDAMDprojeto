import type { Request, Response } from "express";
import { z } from "zod";
import {
  createBooking,
  getBookingById,
  listBookings,
  updateBookingStatus,
  type BookingStatus
} from "../services/bookingService";

const createBookingSchema = z.object({
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

export async function createBookingHandler(req: Request, res: Response) {
  const parsed = createBookingSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  try {
    const created = await createBooking(parsed.data);
    return res.status(201).json(created);
  } catch (error) {
    return res.status(500).json({ error: "failed to create booking" });
  }
}

export async function listBookingsHandler(req: Request, res: Response) {
  const clienteId = req.query.clienteId ? Number(req.query.clienteId) : undefined;
  const prestadorId = req.query.prestadorId ? Number(req.query.prestadorId) : undefined;
  const status = req.query.status ? String(req.query.status) : undefined;

  try {
    const list = await listBookings({
      clienteId,
      prestadorId,
      status: status as BookingStatus | undefined
    });

    return res.json(list);
  } catch (error) {
    return res.status(500).json({ error: "failed to list bookings" });
  }
}

export async function getBookingByIdHandler(req: Request, res: Response) {
  const id = Number(req.params.id);

  try {
    const found = await getBookingById(id);

    if (!found) {
      return res.status(404).json({ error: "booking not found" });
    }

    return res.json(found);
  } catch (error) {
    return res.status(500).json({ error: "failed to load booking" });
  }
}

export async function updateBookingStatusHandler(req: Request, res: Response) {
  const id = Number(req.params.id);
  const parsed = statusSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(zodErrorResponse(parsed.error));
  }

  try {
    const updated = await updateBookingStatus(id, parsed.data.status as BookingStatus);

    if (!updated) {
      return res.status(404).json({ error: "booking not found" });
    }

    return res.json(updated);
  } catch (error) {
    return res.status(500).json({ error: "failed to update booking status" });
  }
}
