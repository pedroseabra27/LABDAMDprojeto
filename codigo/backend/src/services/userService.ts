import { eq } from "drizzle-orm";
import { db } from "../db";
import { usuarios, type UsuarioInsert, type UsuarioSelect } from "../db/schema";

export async function createUser(data: UsuarioInsert): Promise<UsuarioSelect> {
  const [created] = await db.insert(usuarios).values(data).returning();
  return created;
}

export async function listUsers(): Promise<UsuarioSelect[]> {
  return db.select().from(usuarios);
}

export async function getUserById(id: number): Promise<UsuarioSelect | undefined> {
  const [found] = await db.select().from(usuarios).where(eq(usuarios.id, id));
  return found;
}

export async function deleteUserById(id: number): Promise<UsuarioSelect | undefined> {
  const [deleted] = await db.delete(usuarios).where(eq(usuarios.id, id)).returning();
  return deleted;
}
