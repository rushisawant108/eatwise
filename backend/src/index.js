require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase Client using Service Role Key (Bypasses RLS for admin operations)
let supabase = null;
try {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  
  if (supabaseUrl && supabaseKey && supabaseUrl !== "https://your-project-id.supabase.co") {
    supabase = createClient(supabaseUrl, supabaseKey);
    console.log('✅ Supabase Client Initialized Successfully!');
  } else {
    console.log('⚠️ Supabase credentials not fully configured. Using simulated endpoints where applicable.');
  }
} catch (error) {
  console.error('❌ Failed to initialize Supabase:', error.message);
}

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Main health-check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'active', 
    database: supabase ? 'connected' : 'disconnected',
    message: 'EATWISE Supabase Backend is running.', 
    timestamp: new Date() 
  });
});

// Import specific EATWISE AI & tracking routes
const routes = require('./routes/api');
app.use('/api', routes(supabase));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  // console.log(`\n================================`);
  console.log(`🚀 EATWISE SUPABASE BACKEND RUNNING...`);
  console.log(`🌍 PORT: ${PORT}`);
  // console.log(`================================\n`);
});
