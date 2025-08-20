const admin = require('firebase-admin');

// Initialize Firebase Admin with default credentials
try {
  admin.initializeApp({
    projectId: 'aesthetics-lab-1'
  });
} catch (error) {
  console.log('Firebase already initialized or error:', error.message);
}

async function createAdminDoc() {
  try {
    const db = admin.firestore();
    
    const adminData = {
      userID: "admin_mahrukh_2024",
      name: "Mahrukh Tibbi", 
      email: "mahrukh.tibbi@gmail.com",
      role: "admin",
      isActive: true,
      createdAt: "2024-01-15T10:00:00.000Z",
      permissions: [
        "createUsers", "viewUsers", "updateUsers", "deleteUsers",
        "createBranches", "viewBranches", "updateBranches", "deleteBranches", 
        "createDoctors", "viewDoctors", "updateDoctors", "deleteDoctors",
        "createAppointments", "viewAppointments", "updateAppointments", "deleteAppointments",
        "createServices", "viewServices", "updateServices", "deleteServices",
        "createBookings", "viewBookings", "updateBookings", "deleteBookings",
        "viewReports", "viewAnalytics"
      ]
    };

    await db.collection('users').doc('admin_mahrukh_2024').set(adminData);
    console.log('✅ Firestore document created successfully!');
    console.log('🎉 Admin user is ready!');
    console.log('📧 Email: mahrukh.tibbi@gmail.com');
    console.log('🔑 You need to set password in Firebase Console');
    
  } catch (error) {
    console.error('❌ Error creating Firestore document:', error.message);
    
    console.log('\n🔥 MANUAL FIRESTORE SETUP REQUIRED:');
    console.log('1. Go to Firebase Console > Firestore Database');
    console.log('2. Create document in "users" collection');
    console.log('3. Document ID: admin_mahrukh_2024');
    console.log('4. Add these fields:');
    console.log('   userID: admin_mahrukh_2024 (string)');
    console.log('   name: Mahrukh Tibbi (string)');
    console.log('   email: mahrukh.tibbi@gmail.com (string)');
    console.log('   role: admin (string)');
    console.log('   isActive: true (boolean)');
    console.log('   createdAt: 2024-01-15T10:00:00.000Z (string)');
    console.log('   permissions: [all the permissions as array]');
  }
}

createAdminDoc();
