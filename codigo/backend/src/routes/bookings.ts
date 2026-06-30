import { Router } from "express";
import {
  createBookingHandler,
  deleteBookingHandler,
  getBookingByIdHandler,
  listBookingsHandler,
  updateBookingStatusHandler,
  reviewBookingHandler
} from "../controllers/bookingController";

const router = Router();

router.post("/", createBookingHandler);
router.get("/", listBookingsHandler);
router.get("/:id", getBookingByIdHandler);
router.patch("/:id/status", updateBookingStatusHandler);
router.patch("/:id/review", reviewBookingHandler);
router.delete("/:id", deleteBookingHandler);

export default router;
