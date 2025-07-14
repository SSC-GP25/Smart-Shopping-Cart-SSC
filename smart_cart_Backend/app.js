const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const app = express();

const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require("./swagger");

const frontendOrigin = "http://localhost:5173";


// Middleware setup
app.use(express.json());
app.use(cookieParser());

// Import routes
const productRoute = require('./routes/productRoutes');
const categoryRoute = require('./routes/categoryRoutes');
const cartRoutes = require('./routes/cartRoutes');
const userRoutes = require("./routes/userRoutes");
const authRoutes = require('./routes/authRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const recommendationsRoute = require("./routes/recommendationsRoute");
const ratingRoute = require("./routes/ratingRoutes");
const adminRoute = require("./routes/adminRoutes");
const indoorMappingRoutes = require('./routes/indoorMappingRoutes');

// CORS configuration to allow all origins and frontend origin
app.use(cors({
    origin: function (origin, callback) {
        if (!origin || origin === frontendOrigin || origin === '*' || origin === undefined) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true, // Allow cookies and credentials
    methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));


// Handling preflight requests (OPTIONS)
app.options('*', cors({
    origin: function (origin, callback) {
        if (!origin || origin === frontendOrigin || origin === '*') {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Use morgan for logging in development
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

// Middleware to add request time
app.use((req, res, next) => {
    console.log("Hello From Developer in app.js");
    req.requestTime = new Date().toISOString();
    next();
});

// Swagger UI for API docs
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// API Routes
app.use('/api/products', productRoute);
app.use('/api/category', categoryRoute);
app.use('/api/cart', cartRoutes);
app.use("/api/user", userRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/transaction', transactionRoutes);
app.use("/api/recommendations", recommendationsRoute);
app.use("/api/ratings", ratingRoute);
app.use("/api/data", adminRoute);
app.use('/api/navigation', indoorMappingRoutes);

app.use((err, req, res, next) => {
  logger.error("Server error", { error: err.message, stack: err.stack, status: err.statusCode });
  if (!res.headersSent) {
    res.status(err.statusCode || 500).json({ error: err.message });
  }
});


module.exports = app;
