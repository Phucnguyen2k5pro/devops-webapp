require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const os = require('os');
const path = require('path');
const fs = require('fs');
const client = require('prom-client');

const productRoutes = require('./routes/productRoutes');
const dataSource = require('./services/dataSource');
const uiRoutes = require('./routes/uiRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

client.collectDefaultMetrics({ prefix: 'devops_webapp_' });

const httpRequestsTotal = new client.Counter({
  name: 'devops_webapp_http_requests_total',
  help: 'Total number of HTTP requests handled by the application',
  labelNames: ['method', 'path', 'status_code']
});

app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestsTotal.inc({
      method: req.method,
      path: req.path,
      status_code: String(res.statusCode)
    });
  });
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// view engine and static
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    database: {
      source: dataSource.isMongo ? 'mongodb' : 'in-memory',
      mongooseReadyState: mongoose.connection.readyState
    }
  });
});

app.get('/metrics', async (req, res, next) => {
  try {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
  } catch (err) {
    next(err);
  }
});

app.use('/', uiRoutes);
app.use('/products', productRoutes);

async function start() {
  // Ensure uploads directory exists
  const uploadsDir = path.join(__dirname, 'public', 'uploads');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
    console.log(`Created uploads directory at ${uploadsDir}`);
  }

  // Try to connect to MongoDB once with 3s timeout
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/products_db';
  let usingMongo = false;
  try {
    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 3000
    });
    usingMongo = true;
    console.log('Connected to MongoDB - using mongodb as data source.');
  } catch (err) {
    usingMongo = false;
    console.log('Failed to connect to MongoDB within 3s - falling back to in-memory database.');
  }

  await dataSource.init(usingMongo);

  app.listen(PORT, () => {
    console.log(`Server listening on port http://localhost:${PORT} - hostname: ${os.hostname()}`);
    console.log(`Data source in use: ${dataSource.isMongo ? 'mongodb' : 'in-memory'}`);
  });
}

start();

module.exports = app;