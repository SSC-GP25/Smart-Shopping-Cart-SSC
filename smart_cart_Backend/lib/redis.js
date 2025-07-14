const { Redis } = require('ioredis');

const redis = new Redis(
    process.env.REDIS_URL
);

redis.on("error", (error) => {
  console.log("Redis connection error", { error: error.message });
});

redis.on("connect", () => {
  console.log("Connected to Redis");
});

module.exports = {redis};