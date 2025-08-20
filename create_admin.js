const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = {
  // You'll need to add your Firebase service account key here
  // Download from Firebase Console > Project Settings > Service Accounts
};

// For now, let's use the web SDK approach
const { initializeApp } = require('firebase/app');
const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
const { getFirestore, doc, setDoc } = require('firebase/firestore');

const firebaseConfig = {
  // Your Firebase config from Firebase Console > Project Settings > General
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};

async function createAdminUser() {
  try {
    console.log('🔥 Creating admin user for mahrukh.tibbi@gmail.com...');
    
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app);

    // Create Firebase Auth user
    const userCredential = await createUserWithEmailAndPassword(
      auth, 
      'mahrukh.tibbi@gmail.com', 
      'admin123456'
    );
    
    const user = userCredential.user;
    console.log('✅ Firebase Auth user created with UID:', user.uid);

    // Create Firestore document
    const adminData = {
      userID: user.uid,
      name: 'Mahrukh Tibbi',
      email: 'mahrukh.tibbi@gmail.com',
      role: 'admin',
      isActive: true,
      createdAt: new Date().toISOString(),
      permissions: [
        'createUsers', 'viewUsers', 'updateUsers', 'deleteUsers',
        'createBranches', 'viewBranches', 'updateBranches', 'deleteBranches',
        'createDoctors', 'viewDoctors', 'updateDoctors', 'deleteDoctors',
        'createAppointments', 'viewAppointments', 'updateAppointments', 'deleteAppointments',
        'createServices', 'viewServices', 'updateServices', 'deleteServices',
        'createBookings', 'viewBookings', 'updateBookings', 'deleteBookings',
        'viewReports', 'viewAnalytics'
      ]
    };

    await setDoc(doc(db, 'users', user.uid), adminData);
    console.log('✅ Firestore document created');

    console.log('🎉 Admin user created successfully!');
    console.log('📧 Email: mahrukh.tibbi@gmail.com');
    console.log('🔑 Password: admin123456');
    console.log('🆔 UID:', user.uid);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('\n⚠️  MANUAL SETUP REQUIRED:');
    console.log('Go to Firebase Console and create the user manually.');
  }
}

createAdminUser();
