const dotenv = require('dotenv');
dotenv.config({ path: './config.env' });
const app = require('./app');
const mongoose = require('mongoose');
const http = require('http');
const socketIo = require('socket.io');
const gpsSocketController = require('./controllers/gpsSocketController');


// Connect to the database
DB = process.env.DATABASE.replace('<PASSWORD>', process.env.DATABASE_PASSWORD);
mongoose.connect(DB).then(() => {
    console.log('Connected to DataBase...');
}).catch((err) => {
    console.log('Error Connecting to DataBase');
    console.log(err);
});

// Set up the server and socket.io
const server = http.createServer(app);  
const io = socketIo(server, {
    cors: {
        origin: (origin, callback) => {
            const allowedOrigins = [
                "http://localhost:5173",
                "http://127.0.0.1:5501",
                "https://ssc-grad.up.railway.app",
                "http://127.0.0.1:5500",
                "file://",
                undefined   
            ];

            if (!origin || allowedOrigins.includes(origin) || origin === 'null') {
                callback(null, true);  
            } else {
                console.log(`Blocked WebSocket request from origin in Else!: ${origin}`);
                
                callback(new Error("Not allowed by CORS"));
            }
        },
        methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE', 'PATCH'],
        credentials: true
    },
    transports: ['websocket', 'polling'],  // Allow WebSocket & fallback polling
    path: "/socket.io/",
    allowEIO3: true, 
});

app.set('io', io);

gpsSocketController(io);

const port = process.env.PORT || 3000;
server.listen(port,'0.0.0.0', () => {
    console.log(`Server running on port ${port}`);
});
