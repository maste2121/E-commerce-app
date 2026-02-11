const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Correct imports with actual filenames
// app.use(require("./routes/productRoutes"));
// app.use(require("./routes/userRoutes"));
// app.use(require("./routes/orderRoutes"));

// Open app.js and change these lines:

// app.js
app.use("/products", require("./routes/productRoutes"));
app.use("/users", require("./routes/userRoutes"));
app.use("/orders", require("./routes/orderRoutes")); // <--- This fixes the 404 // This adds the "/orders" prefixmodule.exports = app;
