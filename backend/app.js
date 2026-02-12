const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
// app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// 1. Health Check Route (Fixes Render "Bad Gateway" & Port Scan issues)
app.get("/", (req, res) => {
  res.status(200).send("API is running...");
});

// 2. Prefixed Routes (Matches your Flutter paths: /users, /orders, /products)
app.use("/products", require("./routes/productRoutes"));
app.use("/users", require("./routes/userRoutes"));
app.use("/orders", require("./routes/orderRoutes"));

module.exports = app;
