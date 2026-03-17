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
   npm run db:generate
   npm run db:migrate -- --name init
   ```
4. **Start Server**:
   ```bash
   npm run dev
   ```

## Scripts

- `npm run dev`: start server with watch mode (auto-restart on file change)
- `npm start`: start server once (no watch)
- `npm run db:generate`: generate Prisma client
- `npm run db:migrate -- --name <migration_name>`: run Prisma migration
