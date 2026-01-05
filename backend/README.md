# Backend - Top-Up Game

## Setup

1. **Install Dependencies**:
   ```bash
   npm install
   ```
2. **Database**:
   - Ensure you have a PostgreSQL database running.
   - Update `.env` with `DATABASE_URL`.
   ```env
   DATABASE_URL="postgresql://user:password@localhost:5432/topup_game?schema=public"
   JWT_SECRET="changeme"
   ```
3. **Run Migrations**:
   ```bash
   npx prisma generate
   npx prisma migrate dev --name init
   ```
4. **Start Server**:
   ```bash
   npm start
   ```
