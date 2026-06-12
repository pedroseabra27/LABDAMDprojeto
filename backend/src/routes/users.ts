import { Router } from "express";
import {
  createUserHandler,
  deleteUserHandler,
  getUserByIdHandler,
  listUsersHandler
} from "../controllers/userController";

const router = Router();

router.post("/", createUserHandler);
router.get("/", listUsersHandler);
router.get("/:id", getUserByIdHandler);
router.delete("/:id", deleteUserHandler);

export default router;
