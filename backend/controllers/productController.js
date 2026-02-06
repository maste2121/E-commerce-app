const db = require("../config/db");
const SERVER_URL = "http://10.161.160.145:8080";

exports.getProducts = async (_, res) => {
  const [products] = await db.query("SELECT * FROM products");
  res.json(products);
};

exports.createProduct = async (req, res) => {
  const { name, description, price, oldPrice, category } = req.body;
  const imagUrl = req.file
    ? `${SERVER_URL}/uploads/${req.file.filename}`
    : null;

  const [result] = await db.query(
    "INSERT INTO products (name,description,price,oldPrice,imagUrl,category) VALUES (?,?,?,?,?,?)",
    [name, description, price, oldPrice, imagUrl, category]
  );

  res.json({ success: true, id: result.insertId, imagUrl });
};

exports.updateProduct = async (req, res) => {
  const { id } = req.params;
  const { name, description, price, oldPrice, category, imagUrl } = req.body;

  const finalImage = req.file
    ? `${SERVER_URL}/uploads/${req.file.filename}`
    : imagUrl;

  const [result] = await db.query(
    "UPDATE products SET name=?,description=?,price=?,oldPrice=?,imagUrl=?,category=? WHERE id=?",
    [name, description, price, oldPrice, finalImage, category, id]
  );

  if (!result.affectedRows)
    return res.status(404).json({ message: "Product not found" });

  res.json({ success: true, imagUrl: finalImage });
};

exports.deleteProduct = async (req, res) => {
  const [result] = await db.query("DELETE FROM products WHERE id=?", [
    req.params.id,
  ]);
  res.json({ success: !!result.affectedRows });
};

exports.toggleFavorite = async (req, res) => {
  let { isFavorite } = req.body;

  if (isFavorite === 1) isFavorite = true;
  else if (isFavorite === 0) isFavorite = false;
  else return res.status(400).json({ error: "isFavorite must be 1 or 0" });

  const [result] = await db.query(
    "UPDATE products SET isFavorite=? WHERE id=?",
    [isFavorite ? 1 : 0, req.params.id]
  );

  if (!result.affectedRows)
    return res.status(404).json({ message: "Product not found" });

  res.json({ success: true });
};
