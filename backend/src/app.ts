import express from "express";
import bookingsRouter from "./routes/bookings";

export function createApp() {
  const app = express();
  app.use(express.json());

  app.get("/health", (_req, res) => {
    res.json({ status: "ok" });
  });

  app.use("/bookings", bookingsRouter);

  return app;
}
