const { MailtrapClient } = require("mailtrap");

const mailtrapClient = new MailtrapClient({
  token: process.env.MAILTRAP_TOKEN,
  endpoint: process.env.MAILTRAP_ENDPOINT,
});

const sender = {
  email: "hello@demomailtrap.com",
  name: "Mailtrap Test",
};

module.exports = {mailtrapClient, sender};