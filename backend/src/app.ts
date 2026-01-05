import Fastify from 'fastify';
import fastifyJwt from '@fastify/jwt';
import cors from '@fastify/cors';
import { PrismaClient } from '@prisma/client';
import { authRoutes } from './routes/auth';

const prisma = new PrismaClient();
const app = Fastify({ logger: true });

// Register JWT
app.register(fastifyJwt, {
    secret: process.env.JWT_SECRET || 'supersecret'
});

// Register CORS
app.register(cors, {
    origin: true // Allow all origins for development
});

// Decorate authenticate
app.decorate("authenticate", async function (request: any, reply: any) {
    try {
        await request.jwtVerify();
    } catch (err) {
        reply.send(err);
    }
});

// Register Routes
app.register(authRoutes, { prefix: '/api/auth' });

// Root Route
app.get('/', async () => {
    return { message: "Welcome to Top-Up Game Backend API 🚀", status: "running" };
});

// Health Check
app.get('/health', async () => {
    return { status: 'ok', timestamp: new Date() };
});

// Shutdown hook
app.addHook('onClose', async (instance) => {
    await prisma.$disconnect();
});

const start = async () => {
    try {
        await app.listen({ port: 3000, host: '0.0.0.0' });
        console.log('Server running on http://localhost:3000');
    } catch (err) {
        app.log.error(err);
        process.exit(1);
    }
};

start();
