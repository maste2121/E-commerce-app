const router = require("express").Router();
const upload = require("../middlewares/upload");
const c = require("../controllers/productController");

// ✅ Change "/products" to "/"
router.get("/", c.getProducts);

// ✅ Change "/products" to "/"
router.post("/", upload.single("image"), c.createProduct);

// ✅ Change "/products/:id" to "/:id"
router.put("/:id", upload.single("image"), c.updateProduct);

// ✅ Change "/products/:id" to "/:id"
router.delete("/:id", c.deleteProduct);

// ✅ Change "/products/:id/favorite" to "/:id/favorite"
router.put("/:id/favorite", c.toggleFavorite);

module.exports = router;
