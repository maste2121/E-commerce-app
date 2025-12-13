const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/users", require("./routes/userRoutes"));
app.use("/products", require("./routes/productRoutes"));
app.use("/orders", require("./routes/orderRoutes"));

module.exports = app;
