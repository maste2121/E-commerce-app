const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Correct imports with actual filenames
app.use(require("./routes/productRoutes"));
app.use(require("./routes/userRoutes"));
app.use(require("./routes/orderRoutes"));

module.exports = app;
