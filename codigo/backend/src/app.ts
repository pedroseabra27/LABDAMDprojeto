import express from "express";
import bookingsRouter from "./routes/bookings";
import usersRouter from "./routes/users";
import courtsRouter from "./routes/courts";
import authRouter from "./routes/auth";
import { authMiddleware } from "./middlewares/authMiddleware";

export function createApp() {
  const app = express();
  app.use(express.json());

  app.get("/health", (_req, res) => {
    res.json({ status: "ok" });
  });

  app.use("/auth", authRouter);
  app.use("/users", usersRouter);
  app.use("/courts", courtsRouter);
  app.use("/bookings", bookingsRouter);

  return app;
}
