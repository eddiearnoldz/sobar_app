const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.getGoogleMapsApiKeyIos = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const googleMapsApiKeyIos = functions.config().google_maps.ios_api_key;
  console.log("iOS API Key:", googleMapsApiKeyIos);

  return { apiKey: googleMapsApiKeyIos };
});

exports.getGoogleMapsApiKeyAndroid = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const googleMapsApiKeyAndroid = functions.config().google_maps.android_api_key;
  console.log("Android API Key:", googleMapsApiKeyAndroid);

  return { apiKey: googleMapsApiKeyAndroid };
});
