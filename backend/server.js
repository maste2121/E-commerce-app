const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { body, validationResult } = require("express-validator");
const multer = require("multer");
const path = require("path");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] },
});

// ------------------ SOCKET MANAGEMENT ------------------
const customerSockets = {}; // key = customerId, value = socket.id
const adminSockets = []; // store admin socket ids

io.on("connection", (socket) => {
  console.log("🟢 Socket connected: " + socket.id);

  // Register socket as admin
  socket.on("register_admin", () => {
    if (!adminSockets.includes(socket.id)) adminSockets.push(socket.id);
    console.log("Admin registered: " + socket.id);
  });

  // Register socket as customer
  socket.on("register_customer", (customerId) => {
    customerSockets[customerId] = socket.id;
    console.log(`Customer ${customerId} registered: ${socket.id}`);
  });

  socket.on("disconnect", () => {
    console.log("Socket disconnected: " + socket.id);

    // Remove from admin list if present
    const adminIndex = adminSockets.indexOf(socket.id);
    if (adminIndex !== -1) adminSockets.splice(adminIndex, 1);

    // Remove from customer map
    for (const key in customerSockets) {
      if (customerSockets[key] === socket.id) delete customerSockets[key];
    }
  });
});

// Notify all admins when a new order is placed
function notifyAdmins(orderData) {
  adminSockets.forEach((socketId) => {
    io.to(socketId).emit("new_order", orderData);
  });
}

// Notify a specific customer when their order status changes
function notifyCustomer(customerId, statusData) {
  const socketId = customerSockets[customerId];
  if (socketId) io.to(socketId).emit("order_status_update", statusData);
}

// ------------------ DATABASE ------------------
const db = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "",
  database: "ecommerce_db1",
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});
console.log("✅ MySQL connection pool ready!");

// ------------------ JWT ------------------
const JWT_SECRET = "12345678";

// ------------------ MULTER ------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

// ------------------ USERS ------------------
app.get("/users", async (req, res) => {
  try {
    const [users] = await db.query("SELECT id, name, email, role FROM users");
    res.json({ success: true, users });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Failed to fetch users" });
  }
});

app.post("/signup", async (req, res) => {
  const { name, email, password, role, avatarUrl } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({
      success: false,
      error: "Name, email, and password are required.",
    });

  try {
    const [existing] = await db.query("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    if (existing.length > 0)
      return res
        .status(400)
        .json({ success: false, error: "Email already registered." });

    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await db.query(
      "INSERT INTO users (name, email, password, role, avatarUrl) VALUES (?, ?, ?, ?, ?)",
      [name, email, hashedPassword, role || "user", avatarUrl || null]
    );

    res.json({ success: true, id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Server error" });
  }
});

app.post(
  "/signin",
  [body("email").isEmail(), body("password").notEmpty()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    const { email, password } = req.body;
    try {
      const [users] = await db.query("SELECT * FROM users WHERE email = ?", [
        email,
      ]);
      if (users.length === 0)
        return res
          .status(400)
          .json({ success: false, error: "Invalid credentials" });

      const user = users[0];
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch)
        return res
          .status(400)
          .json({ success: false, error: "Invalid credentials" });

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        JWT_SECRET,
        { expiresIn: "7d" }
      );
      res.json({
        success: true,
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          avatarUrl: user.avatarUrl || null,
        },
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: "Server error" });
    }
  }
);

// ------------------ PRODUCTS ------------------
app.post("/products", upload.single("image"), async (req, res) => {
  const { name, description, price, oldPrice, category } = req.body;
  const imagUrl = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    const [result] = await db.query(
      "INSERT INTO products (name, description, price, oldPrice, imagUrl, category) VALUES (?, ?, ?, ?, ?, ?)",
      [name, description, price, oldPrice, imagUrl, category]
    );
    res.json({ success: true, id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add product" });
  }
});

app.put("/products/:id", upload.single("image"), async (req, res) => {
  const { id } = req.params;
  const { name, description, price, oldPrice, category } = req.body;
  const imagUrl = req.file ? `/uploads/${req.file.filename}` : req.body.imagUrl;

  try {
    const [result] = await db.query(
      `UPDATE products SET name = ?, description = ?, price = ?, oldPrice = ?, imagUrl = ?, category = ? WHERE id = ?`,
      [name, description, price, oldPrice, imagUrl, category, id]
    );
    if (result.affectedRows > 0)
      res.json({ success: true, message: "Product updated successfully" });
    else res.status(404).json({ success: false, message: "Product not found" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update product" });
  }
});

app.get("/products", async (req, res) => {
  try {
    const [products] = await db.query("SELECT * FROM products");
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch products" });
  }
});

// ------------------ ORDERS ------------------
app.get("/orders", async (req, res) => {
  try {
    const [results] = await db.query(
      `SELECT o.id, o.customer_id, o.customer_name, o.product_id, o.product_name, o.product_price, o.quantity, o.total_price, o.status, o.order_date
       FROM orders o
       ORDER BY o.id DESC`
    );
    res.json(results);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch orders" });
  }
});

app.post("/orders", async (req, res) => {
  const {
    customer_id,
    customer_name,
    product_id,
    product_name,
    product_price,
    quantity,
  } = req.body;
  if (
    !customer_name ||
    !product_id ||
    !product_name ||
    !product_price ||
    !quantity
  )
    return res.status(400).json({ error: "Invalid input" });

  try {
    const total_price = parseFloat(product_price) * parseFloat(quantity);
    const [result] = await db.query(
      `INSERT INTO orders (customer_id, customer_name, product_id, product_name, product_price, quantity, total_price, status, order_date)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending', NOW())`,
      [
        customer_id || null,
        customer_name,
        product_id,
        product_name,
        product_price,
        quantity,
        total_price,
      ]
    );

    // Notify admins
    notifyAdmins({
      orderId: result.insertId,
      customerName: customer_name,
      productName: product_name,
      totalPrice: total_price,
    });

    res.json({ success: true, orderId: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add order" });
  }
});

app.put("/orders/:id/status", async (req, res) => {
  const { id } = req.params;
  const { status, customer_id } = req.body;

  if (!status) return res.status(400).json({ message: "Status is required" });

  try {
    const [result] = await db.query(
      "UPDATE orders SET status = ? WHERE id = ?",
      [status, id]
    );
    if (result.affectedRows > 0) {
      // Notify the specific customer
      if (customer_id) notifyCustomer(customer_id, { orderId: id, status });
      res.status(200).json({ message: "Status updated successfully" });
    } else {
      res.status(404).json({ message: "Order not found" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Database error", error: err });
  }
});

app.delete("/orders/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await db.query("DELETE FROM orders WHERE id = ?", [id]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete order" });
  }
});

// ------------------ START SERVER ------------------
app.get("/", (req, res) =>
  res.send("🟢 E-commerce API is running successfully!")
);

const PORT = 8080;
server.listen(PORT, () =>
  console.log(`🚀 Server running at http://localhost:${PORT}`)
);
