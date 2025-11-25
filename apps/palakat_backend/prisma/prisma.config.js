// Load environment variables
const path = require('path');
const dotenv = require('dotenv');

// Load .env from parent directory
dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

// Get database URL from environment
const databaseUrl =
  process.env.DATABASE_POSTGRES_URL ||
  `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

module.exports = {
  datasources: {
    db: {
      url: databaseUrl,
    },
  },
};
