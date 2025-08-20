# Simple User Management Setup Guide

## System Overview

Your app now has **2 simple roles**:

1. **Admin** - Can create users + full access to everything
2. **CompOps User** - Full access to all features EXCEPT creating users

## How to Set Up (First Time)

### Step 1: Create Your First Admin User

Since you need an admin to create other users, you'll create the first admin manually in Firestore:

1. **Open Firebase Console** → Go to your project → Firestore Database

2. **Navigate to the `users` collection** (create it if it doesn't exist)

3. **Add a new document** with these exact fields:
   ```json
   {
     "userID": "your-firebase-auth-uid",
     "name": "Your Full Name",
     "email": "your-email@example.com", 
     "role": "admin",
     "isActive": true,
     "createdAt": "2024-01-15T10:00:00.000Z",
     "permissions": [
       "createUsers", "viewUsers", "updateUsers", "deleteUsers",
       "createBranches", "viewBranches", "updateBranches", "deleteBranches",
       "createDoctors", "viewDoctors", "updateDoctors", "deleteDoctors",
       "createAppointments", "viewAppointments", "updateAppointments", "deleteAppointments",
       "createServices", "viewServices", "updateServices", "deleteServices", 
       "createBookings", "viewBookings", "updateBookings", "deleteBookings",
       "viewReports", "viewAnalytics"
     ]
   }
   ```

4. **Create the Firebase Auth account**:
   - Go to Firebase Console → Authentication → Users
   - Click "Add User"
   - Enter the same email and a password
   - Copy the UID and use it as `userID` in step 3

### Step 2: Login and Test

1. **Open your app**
2. **Login** with the email/password you created
3. **You should see the dashboard** with a "User Management" option in the sidebar

## How to Create CompOps Users

### Using the App (Recommended)

1. **Login as Admin**
2. **Click "User Management"** in the sidebar
3. **Click the "+" button** to create a new user
4. **Fill out the form**:
   - Full Name: Required
   - Email: Required (will receive verification email)
   - Password: Required (minimum 6 characters)
   - Role: Select "CompOps User"
5. **Click "Create User"**

The new user will receive an email verification and can then login.

### What CompOps Users Can Do

CompOps users have access to **ALL features** except creating users:
- ✅ Manage branches (create, edit, delete)
- ✅ Manage doctors (create, edit, delete)
- ✅ Manage appointments (create, edit, delete)
- ✅ Manage services (create, edit, delete)
- ✅ Manage bookings (create, edit, delete)
- ✅ View reports and analytics
- ❌ Create or manage users (only admins can do this)

## How Users Login

### Login Process
1. **Open the app**
2. **Enter email and password**
3. **App automatically opens to the main dashboard**

### Email Verification
- New users must verify their email before first login
- They'll receive an email with a verification link
- Until verified, they cannot login

## Managing Users

### View All Users
- Go to "User Management" 
- See all users with their roles and status
- Filter by role or active status

### Edit Users
- Click the edit button on any user
- Change their information or role
- Save changes

### Deactivate Users
- Click the block/unblock button
- Deactivated users cannot login
- This is like "soft delete" - you can reactivate them later

## Troubleshooting

### "Can't see User Management menu"
- Only Admins can see this menu
- Check that your user has role "admin" in Firestore

### "Login fails"
- Check email is verified (check spam folder for verification email)
- Check user is active (isActive: true) in Firestore
- Check password is correct

### "Permission denied"
- Check user role and permissions in Firestore
- CompOps users cannot create users
- Make sure isActive is true

## Quick Reference

### Admin Capabilities
- ✅ Create users
- ✅ All other features

### CompOps User Capabilities  
- ❌ Create users
- ✅ All other features

### Login Flow
1. Enter email/password
2. System checks if user is active
3. System checks email verification
4. Redirects to main dashboard
5. Menu items show/hide based on permissions

That's it! Your system is now ready for production use.
