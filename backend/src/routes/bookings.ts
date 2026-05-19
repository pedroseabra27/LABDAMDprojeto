import { Router } from "express";
import {
  createBookingHandler,
  getBookingByIdHandler,
  listBookingsHandler,
  updateBookingStatusHandler
} from "../controllers/bookingController";

const router = Router();

router.post("/", createBookingHandler);
router.get("/", listBookingsHandler);
router.get("/:id", getBookingByIdHandler);
router.patch("/:id/status", updateBookingStatusHandler);

export default router;
