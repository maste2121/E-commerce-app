const router = require("express").Router();
const c = require("../controllers/orderController");

router.get("/", c.getOrders);
router.post("/", c.createOrder);
router.put("/:id/status", c.updateStatus);
router.delete("/:id", c.deleteOrder);

module.exports = router;
