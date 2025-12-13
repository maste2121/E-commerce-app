const db = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "12345678";

exports.getUsers = async (_, res) => {
  const [users] = await db.query("SELECT id,name,email,role FROM users");
  res.json({ success: true, users });
};

exports.signup = async (req, res) => {
  const { name, email, password, role, avatarUrl } = req.body;

  const [existing] = await db.query("SELECT id FROM users WHERE email=?", [
    email,
  ]);
  if (existing.length)
    return res.status(400).json({ error: "Email already exists" });

  const hashed = await bcrypt.hash(password, 10);
  const [result] = await db.query(
    "INSERT INTO users (name,email,password,role,avatarUrl) VALUES (?,?,?,?,?)",
    [name, email, hashed, role || "user", avatarUrl || null]
  );

  res.json({ success: true, id: result.insertId });
};

exports.signin = async (req, res) => {
  const { email, password } = req.body;

  const [users] = await db.query("SELECT * FROM users WHERE email=?", [email]);
  if (!users.length)
    return res.status(400).json({ error: "Invalid credentials" });

  const user = users[0];
  if (!(await bcrypt.compare(password, user.password)))
    return res.status(400).json({ error: "Invalid credentials" });

  const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, {
    expiresIn: "7d",
  });

  res.json({ success: true, token, user });
};

exports.getMe = async (req, res) => {
  try {
    const [users] = await db.query(
      "SELECT id, name, email, role, avatarUrl FROM users WHERE id = ?",
      [req.user.id]
    );

    if (!users.length) return res.status(404).json({ error: "User not found" });

    res.json({ success: true, user: users[0] });
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};
