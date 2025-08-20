// Simple Node.js script to create admin user properly
const https = require('https');

console.log('🔥 FIXING ADMIN PASSWORD...');
console.log('');

// The user exists but needs password set
console.log('⚠️  MANUAL PASSWORD SETUP REQUIRED:');
console.log('');
console.log('1. Go to: https://console.firebase.google.com');
console.log('2. Select your project: aesthetics-lab-1');
console.log('3. Authentication → Users');
console.log('4. Find user: mahrukh.tibbi@gmail.com');
console.log('5. Click the user → Actions → Reset password');
console.log('6. Set new password: admin123456');
console.log('7. Enable the user if disabled');
console.log('');
console.log('THEN add Firestore document:');
console.log('');
console.log('8. Firestore Database → users collection');
console.log('9. Add document with ID: admin_mahrukh_2024');
console.log('10. Add these fields:');
console.log('    userID: admin_mahrukh_2024 (string)');
console.log('    name: Mahrukh Tibbi (string)');
console.log('    email: mahrukh.tibbi@gmail.com (string)');
console.log('    role: admin (string)');
console.log('    isActive: true (boolean)');
console.log('    createdAt: 2024-01-15T10:00:00.000Z (string)');
console.log('    permissions: (array with all permissions)');
console.log('');
console.log('11. Go to http://localhost:8080 and try login again!');
console.log('');
console.log('🎉 This will fix the authentication issue!');
