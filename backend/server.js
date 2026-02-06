const http = require("http");
const app = require("./app");
const initSocket = require("./services/socketManager");
const orderController = require("./controllers/orderController");

const server = http.createServer(app);
const socketService = initSocket(server);

orderController.attachSocket(socketService);

// CHANGE THIS PART:
const PORT = process.env.PORT || 10000; // Use Render's port or default to 10000

server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
