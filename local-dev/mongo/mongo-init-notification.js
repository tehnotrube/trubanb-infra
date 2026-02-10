// MongoDB initialization script for notification service
// This script creates the notificationservice user with appropriate permissions

db = db.getSiblingDB('notificationsdb');

db.createUser({
  user: 'notificationservice',
  pwd: 'notificationpass123',
  roles: [
    {
      role: 'readWrite',
      db: 'notificationsdb'
    }
  ]
});

print('MongoDB user "notificationservice" created successfully for database "notificationsdb"');
