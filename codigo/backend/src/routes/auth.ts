import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { db } from "../db";
import { usuarios } from "../db/schema";
import { eq } from "drizzle-orm";

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "super_secret_jwt_key_123";

// POST /auth/register
router.post("/register", async (req, res) => {
  try {
    const { nome, email, senha, tipo } = req.body;
    
    if (!nome || !email || !senha || !tipo) {
      return res.status(400).json({ error: "Todos os campos são obrigatórios." });
    }

    const hashSenha = await bcrypt.hash(senha, 10);

    const [novoUsuario] = await db.insert(usuarios).values({
      nome,
      email,
      senha: hashSenha,
      tipo
    }).returning();

    res.status(201).json({
      id: novoUsuario.id,
      nome: novoUsuario.nome,
      email: novoUsuario.email,
      tipo: novoUsuario.tipo
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erro ao criar usuário (email já existe?)." });
  }
});

// POST /auth/login
router.post("/login", async (req, res) => {
  try {
    const { email, senha } = req.body;

    const [usuario] = await db.select().from(usuarios).where(eq(usuarios.email, email));
    
    if (!usuario) {
      return res.status(401).json({ error: "Credenciais inválidas." });
    }

    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) {
      return res.status(401).json({ error: "Credenciais inválidas." });
    }

    const token = jwt.sign(
      { id: usuario.id, tipo: usuario.tipo },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        tipo: usuario.tipo
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erro ao fazer login." });
  }
});

export default router;
