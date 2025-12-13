const http = require("http");
const app = require("./app");
const initSocket = require("./services/socketManager");
const orderController = require("./controllers/orderController");

const server = http.createServer(app);
const socketService = initSocket(server);

orderController.attachSocket(socketService);

server.listen(8080, "0.0.0.0", () => {
  console.log("🚀 Server running on port 8080");
});
