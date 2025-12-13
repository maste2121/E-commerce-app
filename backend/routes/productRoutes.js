const router = require("express").Router();
const upload = require("../middlewares/upload");
const c = require("../controllers/productController");
const { authenticate, authorize } = require("../middlewares/auth");
const { validate } = require("../middlewares/validate");
const rules = require("./validators/product.validators");

/**
 * Public
 */
router.get("/", c.getProducts);

/**
 * 🔐 Admin only – create product
 */
router.post(
  "/",
  authenticate,
  authorize("admin"),
  upload.single("image"),
  validate(rules.createProduct),
  c.createProduct
);

/**
 * 🔐 Admin only – update product
 */
router.put(
  "/:id",
  authenticate,
  authorize("admin"),
  upload.single("image"),
  c.updateProduct
);

/**
 * 🔐 Admin only – delete product
 */
router.delete("/:id", authenticate, authorize("admin"), c.deleteProduct);

/**
 * 🔐 Logged-in users – favorite toggle
 */
router.put("/:id/favorite", authenticate, c.toggleFavorite);

module.exports = router;
