import { eq } from "drizzle-orm";
import { db } from "../db";
import { quadras, type QuadraInsert, type QuadraSelect } from "../db/schema";

export async function createCourt(data: QuadraInsert): Promise<QuadraSelect> {
  const [created] = await db.insert(quadras).values(data).returning();
  return created;
}

export async function listCourts(): Promise<QuadraSelect[]> {
  return db.select().from(quadras);
}

export async function getCourtById(id: number): Promise<QuadraSelect | undefined> {
  const [found] = await db.select().from(quadras).where(eq(quadras.id, id));
  return found;
}

export async function deleteCourtById(id: number): Promise<QuadraSelect | undefined> {
  const [deleted] = await db.delete(quadras).where(eq(quadras.id, id)).returning();
  return deleted;
}
