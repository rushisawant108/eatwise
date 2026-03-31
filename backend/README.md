# EATWISE Supabase Backend Server

This is the independent Node.js REST API layer structure for the **EATWISE Behavioral Health Tracker**. 
It utilizes **Express.js** and interfaces directly with **Supabase (PostgreSQL)**. By keeping this logic separate from the client, we ensure mobile-first architecture separation, heavy data analysis scaling, and highly secure biometric data processing.

## 📁 Architecture Overview
```text
backend/
├── src/
│   ├── index.js          // Main Entry, Express Configuration & Supabase Initialization
│   └── routes/
│       └── api.js        // AI Endpoints, Food Logging, PostgreSQL Access
├── package.json
└── README.md
```

## 🚀 Getting Started

1. **Install Dependencies**:
```bash
npm install
```

2. **Configure Supabase keys**:
Navigate to your Supabase project dashboard (`Project Settings` > `API`).
Copy the **Project URL** and the **`service_role`** secret key (do NOT use the `anon_key` for the backend).

Create/update your `.env` file in the root of the backend folder:
```env
PORT=5000
SUPABASE_URL="https://your-project-id.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-secret-service-role-key"
```

3. **Start Development Server**:
```bash
npm run dev
```
The server will be available at `http://localhost:5000/api/health`

## 🧠 Why Node + Supabase?
This combination operates harmoniously with the native Flutter `AppProvider`. Rather than the mobile device generating complex string matches or analyzing camera buffers securely on Firebase, we utilize **Supabase** for its robust **PostgreSQL** relational database.
This allows us to seamlessly map `Users` -> `FoodLogs` using Foreign Key constraints, maintaining perfect data integrity while the AI microservice crunches the data separately!
