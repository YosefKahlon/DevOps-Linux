const { Client } = require('pg');
const express = require('express');
const morgan = require('morgan');

const app = express();

const connectionString = process.env.DATABASE_URL || 'postgres://myuser:mypassword@db:5432/mydb';

const client = new Client({
  connectionString: connectionString,
});

// Use morgan for HTTP request logging
app.use(morgan('combined'));

// Example route
app.get('/', (req, res) => {
  res.send('Hello, World!');
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

async function checkDatabaseConnection() {
  console.log(`Attempting to connect to database...`);
  try {
    await client.connect();
    console.log('Successfully connected to PostgreSQL database!');
    // const res = await client.query('SELECT NOW()');
    // console.log('Current time from DB:', res.rows[0].now);
  } catch (err) {
    console.error('Error connecting to PostgreSQL database:', err.stack);
    process.exit(1);
  } 
  // finally {
  //   await client.end();
  //   console.log('Database client disconnected.');
  // }
}

checkDatabaseConnection();
