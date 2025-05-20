/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer')

// Configure Nodemailer (Gmail example)
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'fproject219@gmail.com',  // Replace with your email
      pass: '11JM2421',     // Use an "App Password" from Gmail
    },
  });
  // Cloud Function triggered by Firestore writes
exports.sendEmail = functions.firestore
.document('mail/{mailId}')
.onCreate((snap, context) => {
  const mailData = snap.data();

  const mailOptions = {
    from: 'ArtsWell <your-email@gmail.com>',
    to: mailData.to,
    subject: mailData.message.subject,
    html: mailData.message.html,
  };

  return transporter.sendMail(mailOptions)
    .then(() => snap.ref.delete())  // Delete the doc after sending
    .catch((error) => {
      console.error('Email failed:', error);
    });
});



// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
