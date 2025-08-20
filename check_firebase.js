// Simple Firebase check script
const admin = require('firebase-admin');

// Initialize Firebase Admin with your project
try {
  admin.initializeApp({
    projectId: 'aesthetics-lab-1'
  });

  console.log('🔍 CHECKING FIREBASE SETUP...');
  console.log('');

  // Check Auth users
  admin.auth().listUsers(1000)
    .then((listUsersResult) => {
      console.log('📧 FIREBASE AUTH USERS:');
      const targetUser = listUsersResult.users.find(user => user.email === 'mahrukh.tibbi@gmail.com');
      
      if (targetUser) {
        console.log('✅ Found user:', targetUser.email);
        console.log('🆔 UID:', targetUser.uid);
        console.log('🔓 Email verified:', targetUser.emailVerified);
        console.log('🚫 Disabled:', targetUser.disabled);
        
        // Check Firestore document
        return admin.firestore().collection('users').doc(targetUser.uid).get();
      } else {
        console.log('❌ No user found with email: mahrukh.tibbi@gmail.com');
        console.log('');
        console.log('🔧 SOLUTION: Create user in Firebase Console:');
        console.log('1. Go to Authentication → Users → Add user');
        console.log('2. Email: mahrukh.tibbi@gmail.com');
        console.log('3. Password: admin123456');
        return null;
      }
    })
    .then((doc) => {
      if (doc) {
        console.log('');
        console.log('📄 FIRESTORE DOCUMENT:');
        if (doc.exists) {
          console.log('✅ Document exists');
          console.log('📋 Data:', JSON.stringify(doc.data(), null, 2));
        } else {
          console.log('❌ No Firestore document found');
          console.log('');
          console.log('🔧 SOLUTION: Create Firestore document');
        }
      }
    })
    .catch((error) => {
      console.log('❌ Error:', error.message);
    });

} catch (error) {
  console.log('❌ Firebase Admin initialization failed:', error.message);
  console.log('');
  console.log('🔧 MANUAL CHECK REQUIRED:');
  console.log('1. Open Firebase Console');
  console.log('2. Check Authentication → Users');
  console.log('3. Check Firestore Database → users collection');
}
