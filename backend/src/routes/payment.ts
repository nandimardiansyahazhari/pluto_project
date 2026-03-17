import { FastifyInstance } from 'fastify';

type VerifyPaymentBody = {
    buyerSkuCode?: string;
    amount?: number;
    customerNo?: string;
};

function buildReferenceId(): string {
    return `PAY-${Date.now()}`;
}

export async function paymentRoutes(app: FastifyInstance) {
    app.post('/verify', async (request, reply) => {
        const { buyerSkuCode, amount, customerNo } = request.body as VerifyPaymentBody;

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

        return reply.send({
            success: true,
            status: 'PAID',
            buyerSkuCode,
            amount,
            customerNo: customerNo ?? null,
            referenceId: buildReferenceId(),
            source: 'mock',
            message: 'Payment verified successfully',
        });
    });
}