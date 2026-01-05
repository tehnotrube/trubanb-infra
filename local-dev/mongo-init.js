// MongoDB initialization script for rating service
// This script creates the ratingservice user with appropriate permissions

db = db.getSiblingDB('ratingsdb');

db.createUser({
  user: 'ratingservice',
  pwd: 'ratingpass123',
  roles: [
    {
      role: 'readWrite',
      db: 'ratingsdb'
    }
  ]
});

print('MongoDB user "ratingservice" created successfully for database "ratingsdb"');
