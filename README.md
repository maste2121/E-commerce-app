# Asrat Project

A full-stack project with a **Flutter frontend** and **Node.js backend** using MySQL. This project demonstrates a simple app structure with backend API support and a cross-platform Flutter frontend.

## ⚙️ Backend Setup (Node.js + MySQL)

1. Navigate to the backend folder:
   ```bash
   cd backend
   Install dependencies:
   ```

npm install
Configure your MySQL database connection in server.js or in a separate config file.

Start the backend server:

node server.js
Server will run at: http://localhost:8080

📱 Frontend Setup (Flutter)
Navigate to the asrat folder:

cd asrat
Get Flutter dependencies:

flutter pub get
Run the app:

flutter run
🔗 GitHub Repo Setup
Initialize git in the root folder:

git init
Add all files:

git add .
Commit the changes:

git commit -m "Initial commit"
Create a new repository on GitHub

Add the GitHub remote:

git remote add origin https://github.com/maste2121/asrat.git
Push the project:

git branch -M main
git push -u origin main
📌 Notes
Make sure MySQL server is running before starting the backend.

Adjust any environment variables or database credentials in your backend config.

Flutter app communicates with the backend at http://localhost:8080 by default. Update endpoints if needed.

🛠 Tech Stack
Frontend: Flutter, Dart

Backend: Node.js, Express.js

Database: MySQL

Version Control: Git, GitHub

🎯 Author
Mastewal Kihnet Aragie
Email: mastewalkihnet@gmail.com
