import { FastifyInstance } from 'fastify';
import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

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
}
