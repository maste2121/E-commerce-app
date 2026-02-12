const db = require("../config/db");

// ✅ Fetch all products
exports.getProducts = async (_, res) => {
  try {
    const [products] = await db.query(
      "SELECT * FROM products ORDER BY id DESC"
    );
    res.json(products);
  } catch (error) {
    console.error("❌ getProducts Error:", error.message);
    res.status(500).json({ error: error.message });
  }
};

// ✅ Create Product (Fixed for Cloudinary)
exports.createProduct = async (req, res) => {
  try {
    const { name, description, price, oldPrice, category } = req.body;

    // When using Cloudinary storage, req.file.path is the full HTTPS URL
    const imagUrl = req.file ? req.file.path : null;

    const [result] = await db.query(
      "INSERT INTO products (name,description,price,oldPrice,imagUrl,category) VALUES (?,?,?,?,?,?)",
      [name, description, price, oldPrice, imagUrl, category]
    );

    res.status(201).json({ success: true, id: result.insertId, imagUrl });
  } catch (error) {
    console.error("❌ createProduct Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ Update Product (Fixed for Cloudinary)
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, oldPrice, category, imagUrl } = req.body;

    // If a new file is uploaded, use req.file.path (Cloudinary URL).
    // Otherwise, keep the existing imagUrl.
    const finalImage = req.file ? req.file.path : imagUrl;

    const [result] = await db.query(
      "UPDATE products SET name=?,description=?,price=?,oldPrice=?,imagUrl=?,category=? WHERE id=?",
      [name, description, price, oldPrice, finalImage, category, id]
    );

    if (!result.affectedRows)
      return res.status(404).json({ message: "Product not found" });

    res.json({ success: true, imagUrl: finalImage });
  } catch (error) {
    console.error("❌ updateProduct Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ Delete Product
exports.deleteProduct = async (req, res) => {
  try {
    const [result] = await db.query("DELETE FROM products WHERE id=?", [
      req.params.id,
    ]);
    res.json({ success: !!result.affectedRows });
  } catch (error) {
    console.error("❌ deleteProduct Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ Toggle Favorite
exports.toggleFavorite = async (req, res) => {
  try {
    let { isFavorite } = req.body;

    // Convert 1/0 or boolean to database format
    const favoriteValue = isFavorite === 1 || isFavorite === true ? 1 : 0;

    const [result] = await db.query(
      "UPDATE products SET isFavorite=? WHERE id=?",
      [favoriteValue, req.params.id]
    );

    if (!result.affectedRows)
      return res.status(404).json({ message: "Product not found" });

    res.json({ success: true });
  } catch (error) {
    console.error("❌ toggleFavorite Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};
