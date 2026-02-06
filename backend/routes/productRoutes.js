const router = require("express").Router();
const upload = require("../middlewares/upload");
const c = require("../controllers/productController");

router.get("/products", c.getProducts);
router.post("/products", upload.single("image"), c.createProduct);
router.put("/products/:id", upload.single("image"), c.updateProduct);
router.delete("/products/:id", c.deleteProduct);
router.put("/products/:id/favorite", c.toggleFavorite);

module.exports = router;
