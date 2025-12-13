const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "12345678";

/**
 * Verify JWT token
 */
exports.authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(" ")[1];

  if (!token) return res.status(401).json({ error: "No token provided" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, role }
    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
};

/**
 * Allow only specific roles
 */
exports.authorize =
  (...roles) =>
  (req, res, next) => {
    if (!roles.includes(req.user.role))
      return res.status(403).json({ error: "Access denied" });
    next();
  };
