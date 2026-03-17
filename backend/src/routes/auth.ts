import { FastifyInstance } from 'fastify';
import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const demoUsers = [
    {
        email: 'demo1@pluto.local',
        password: 'demo123',
        fullName: 'Demo User One',
        balance: 150000,
        seedTransactions: [
            {
                type: 'TOPUP',
                amount: 30000,
                status: 'DONE',
                description: 'Mobile Legends 100 Diamonds',
                referenceId: 'DEMO1-DONE-001',
            },
            {
                type: 'TOPUP',
                amount: 14000,
                status: 'PENDING',
                description: 'Mobile Legends 50 Diamonds',
                referenceId: 'DEMO1-PENDING-001',
            },
            {
                type: 'TOPUP',
                amount: 75000,
                status: 'CANCELED',
                description: 'PUBG Mobile 325 UC',
                referenceId: 'DEMO1-CANCELED-001',
            },
        ],
    },
    {
        email: 'demo2@pluto.local',
        password: 'demo123',
        fullName: 'Demo User Two',
        balance: 90000,
        seedTransactions: [
            {
                type: 'TOPUP',
                amount: 15000,
                status: 'DONE',
                description: 'Free Fire 100 Diamonds',
                referenceId: 'DEMO2-DONE-001',
            },
            {
                type: 'TOPUP',
                amount: 3000,
                status: 'DONE',
                description: 'Mobile Legends 10 Diamonds',
                referenceId: 'DEMO2-DONE-002',
            },
        ],
    },
];

export async function authRoutes(app: FastifyInstance) {
    // Register Endpoint
    app.post('/register', async (request, reply) => {
        const { email, password, fullName } = request.body as any;

        if (!email || !password) {
            return reply.code(400).send({ error: 'Email and password are required' });
        }

        try {
            // Check if user exists
            const existingUser = await prisma.user.findUnique({ where: { email } });
            if (existingUser) {
                return reply.code(409).send({ error: 'User already exists' });
            }

            // Hash password
            const passwordHash = await bcrypt.hash(password, 10);

            // Create User & Wallet (Transaction)
            const newUser = await prisma.$transaction(async (tx) => {
                const user = await tx.user.create({
                    data: {
                        email,
                        passwordHash,
                        fullName,
                    },
                });

                // Create empty wallet for the user
                await tx.wallet.create({
                    data: {
                        userId: user.id,
                        balance: 0,
                    },
                });

                return user;
            });

            return reply.code(201).send({
                message: 'User registered successfully',
                userId: newUser.id,
                email: newUser.email,
            });

        } catch (error) {
            app.log.error(error);
            return reply.code(500).send({ error: 'Internal Server Error' });
        }
    });

    // Login Endpoint
    app.post('/login', async (request, reply) => {
        const { email, password } = request.body as any;

        if (!email || !password) {
            return reply.code(400).send({ error: 'Email and password are required' });
        }

        try {
            // Find User
            const user = await prisma.user.findUnique({ where: { email } });
            if (!user) {
                return reply.code(401).send({ error: 'Invalid email or password' });
            }

            // Check Password
            const validPassword = await bcrypt.compare(password, user.passwordHash);
            if (!validPassword) {
                return reply.code(401).send({ error: 'Invalid email or password' });
            }

            // Generate JWT
            const token = app.jwt.sign(
                { id: user.id, email: user.email },
                { expiresIn: '7d' } // 7 days token
            );

            return reply.send({
                message: 'Login successful',
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    fullName: user.fullName,
                }
            });

        } catch (error) {
            app.log.error(error);
            return reply.code(500).send({ error: 'Internal Server Error' });
        }
    });

    // Me Endpoint (Verify Token)
    app.get('/me', {
        onRequest: [(app as any).authenticate]
    }, async (request, reply) => {
        return request.user;
    });

    // Seed demo accounts and transactions for local testing.
    app.post('/seed-demo', async (_request, reply) => {
        try {
            for (const demo of demoUsers) {
                const passwordHash = await bcrypt.hash(demo.password, 10);

                const user = await prisma.user.upsert({
                    where: { email: demo.email },
                    update: {
                        passwordHash,
                        fullName: demo.fullName,
                    },
                    create: {
                        email: demo.email,
                        passwordHash,
                        fullName: demo.fullName,
                    },
                });

                const wallet = await prisma.wallet.upsert({
                    where: { userId: user.id },
                    update: {
                        balance: demo.balance,
                        currency: 'IDR',
                    },
                    create: {
                        userId: user.id,
                        balance: demo.balance,
                        currency: 'IDR',
                    },
                });

                const txCount = await prisma.transaction.count({
                    where: { walletId: wallet.id },
                });

                if (txCount === 0) {
                    await prisma.transaction.createMany({
                        data: demo.seedTransactions.map((tx) => ({
                            walletId: wallet.id,
                            type: tx.type,
                            amount: tx.amount,
                            status: tx.status,
                            description: tx.description,
                            referenceId: tx.referenceId,
                        })),
                    });
                }
            }

            return reply.send({
                message: 'Demo accounts are ready',
                accounts: demoUsers.map((u) => ({
                    email: u.email,
                    password: u.password,
                })),
            });
        } catch (error) {
            app.log.error(error);
            return reply.code(500).send({ error: 'Failed to seed demo accounts' });
        }
    });
}
