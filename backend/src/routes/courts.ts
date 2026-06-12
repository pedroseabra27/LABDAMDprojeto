import { Router } from "express";
import {
  createCourtHandler,
  deleteCourtHandler,
  getCourtByIdHandler,
  listCourtsHandler
} from "../controllers/courtController";

const router = Router();

router.post("/", createCourtHandler);
router.get("/", listCourtsHandler);
router.get("/:id", getCourtByIdHandler);
router.delete("/:id", deleteCourtHandler);

export default router;
