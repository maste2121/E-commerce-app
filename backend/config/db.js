const mysql = require("mysql2/promise");
require("dotenv").config();

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 23751, // Uses your Aiven port

  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,

  // Aiven REQUIRES this SSL setting to allow the connection
  ssl: {
    rejectUnauthorized: false,
  },
});

// Test the connection logic
db.getConnection()
  .then((conn) => {
    console.log("✅ Connected to Aiven MySQL successfully!");
    conn.release();
  })
  .catch((err) => {
    console.error("❌ Database connection failed:", err.message);
  });

module.exports = db;
