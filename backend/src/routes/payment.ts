import { FastifyInstance } from 'fastify';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

type VerifyPaymentBody = {
    buyerSkuCode?: string;
    amount?: number;
    customerNo?: string;
};

function buildReferenceId(): string {
    return `PAY-${Date.now()}`;
}

export async function paymentRoutes(app: FastifyInstance) {
    app.post('/verify', {
        onRequest: [(app as any).authenticate],
    }, async (request, reply) => {
        const { buyerSkuCode, amount, customerNo } = request.body as VerifyPaymentBody;
        const userId = (request.user as any)?.id as string | undefined;

        if (!userId) {
            return reply.code(401).send({ error: 'Unauthorized' });
        }

        if (!buyerSkuCode || !amount) {
            return reply.code(400).send({
                error: 'buyerSkuCode and amount are required',
            });
        }

        if (typeof amount !== 'number' || amount <= 0) {
            return reply.code(400).send({
                error: 'amount must be a positive number',
            });
        }

        await new Promise((resolve) => setTimeout(resolve, 800));

        const wallet = await prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            return reply.code(404).send({
                error: 'Wallet not found for this user',
            });
        }

        const referenceId = buildReferenceId();

        const createdTransaction = await prisma.transaction.create({
            data: {
                walletId: wallet.id,
                type: 'TOPUP',
                amount,
                status: 'DONE',
                description: `Top up ${buyerSkuCode}`,
                referenceId,
            },
        });

        return reply.send({
            success: true,
            status: 'PAID',
            buyerSkuCode,
            amount,
            customerNo: customerNo ?? null,
            referenceId,
            transactionId: createdTransaction.id,
            source: 'mock',
            message: 'Payment verified successfully',
        });
    });
}