const db = require("../config/db");

let socketService;

exports.attachSocket = (service) => {
  socketService = service;
};

// ✅ GET ORDERS (Fixed with try-catch)
exports.getOrders = async (_, res) => {
  try {
    const [orders] = await db.query("SELECT * FROM orders ORDER BY id DESC");
    res.status(200).json(orders);
  } catch (error) {
    console.error("❌ getOrders Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ CREATE ORDER (Fixed with try-catch)
exports.createOrder = async (req, res) => {
  try {
    const {
      customer_id,
      customer_name,
      product_id,
      product_name,
      product_price,
      quantity,
    } = req.body;

    const total = product_price * quantity;

    const [result] = await db.query(
      `INSERT INTO orders 
       (customer_id, customer_name, product_id, product_name, product_price, quantity, total_price, status, order_date)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending', NOW())`,
      [
        customer_id || null,
        customer_name,
        product_id,
        product_name,
        product_price,
        quantity,
        total,
      ]
    );

    socketService?.notifyAdmins({
      orderId: result.insertId,
      customerName: customer_name,
      totalPrice: total,
    });

    res.status(201).json({ success: true, orderId: result.insertId });
  } catch (error) {
    console.error("❌ createOrder Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ UPDATE STATUS (Fixed with try-catch)
exports.updateStatus = async (req, res) => {
  try {
    const { status, customer_id } = req.body;

    await db.query("UPDATE orders SET status=? WHERE id=?", [
      status,
      req.params.id,
    ]);

    socketService?.notifyCustomer(customer_id, {
      orderId: req.params.id,
      status,
    });

    res.status(200).json({ success: true });
  } catch (error) {
    console.error("❌ updateStatus Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};

// ✅ DELETE ORDER (Fixed with try-catch)
exports.deleteOrder = async (req, res) => {
  try {
    await db.query("DELETE FROM orders WHERE id=?", [req.params.id]);
    res.status(200).json({ success: true });
  } catch (error) {
    console.error("❌ deleteOrder Error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};
