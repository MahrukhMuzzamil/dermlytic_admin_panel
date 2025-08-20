// Simple script to add Firestore document
// You need to run this in Firebase Console > Firestore > Query

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

console.log('Add this document to Firestore:');
console.log('Collection: users');
console.log('Document ID: admin_mahrukh_2024');
console.log('Data:', JSON.stringify(adminData, null, 2));
