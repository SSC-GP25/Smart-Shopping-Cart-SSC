const http = require('http');
const ngrok = require('@ngrok/ngrok');
const dotenv = require('dotenv');
dotenv.config({ path: './config.env' });

// Ensure ngrok authtoken is set (required for authenticated tunnels)
const ngrokAuthtoken = process.env.NGROK_AUTHTOKEN; // Your ngrok authtoken
if (!ngrokAuthtoken) {
  console.error('NGROK_AUTHTOKEN is not set in .env file. Please add it.');
  process.exit(1);
}
/// Create webserver
http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end('Congrats you have created an ngrok web server');
}).listen(8080, () => console.log('Node.js web server at 8080 is running...'));

// Configure ngrok with authtoken and create tunnel
ngrok.authtoken(ngrokAuthtoken); // Authenticate ngrok
ngrok.connect({ addr: 8080, authtoken: ngrokAuthtoken })
  .then(listener => {
    console.log(`Ingress established at: ${listener.url()}`)
  })
  .catch(err => console.error('Error setting up ngrok:', err));