import { FastifyInstance } from 'fastify';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function transactionRoutes(app: FastifyInstance) {
  app.get(
    '/me',
    {
      onRequest: [(app as any).authenticate],
    },
    async (request, reply) => {
      try {
        const userId = (request.user as any)?.id as string | undefined;
        if (!userId) {
          return reply.code(401).send({ error: 'Unauthorized' });
        }

        const wallet = await prisma.wallet.findUnique({
          where: { userId },
        });

        if (!wallet) {
          return reply.send({ transactions: [] });
        }

        const transactions = await prisma.transaction.findMany({
          where: { walletId: wallet.id },
          orderBy: { createdAt: 'desc' },
        });

        return reply.send({
          transactions: transactions.map((tx) => ({
            id: tx.id,
            type: tx.type,
            amount: Number(tx.amount),
            status: tx.status,
            description: tx.description,
            referenceId: tx.referenceId,
            createdAt: tx.createdAt,
          })),
        });
      } catch (error) {
        app.log.error(error);
        return reply.code(500).send({ error: 'Failed to fetch transactions' });
      }
    },
  );

  app.post(
    '/:id/cancel',
    {
      onRequest: [(app as any).authenticate],
    },
    async (request, reply) => {
      try {
        const userId = (request.user as any)?.id as string | undefined;
        const txId = (request.params as any)?.id as string | undefined;

        if (!userId) {
          return reply.code(401).send({ error: 'Unauthorized' });
        }

        if (!txId) {
          return reply.code(400).send({ error: 'Transaction id is required' });
        }

        const wallet = await prisma.wallet.findUnique({ where: { userId } });
        if (!wallet) {
          return reply.code(404).send({ error: 'Wallet not found' });
        }

        const tx = await prisma.transaction.findUnique({ where: { id: txId } });
        if (!tx || tx.walletId != wallet.id) {
          return reply.code(404).send({ error: 'Transaction not found' });
        }

        if (tx.status != 'PENDING') {
          return reply.code(400).send({ error: 'Only PENDING transactions can be canceled' });
        }

        const updated = await prisma.transaction.update({
          where: { id: tx.id },
          data: { status: 'CANCELED' },
        });

        return reply.send({
          message: 'Transaction canceled',
          transaction: {
            id: updated.id,
            status: updated.status,
          },
        });
      } catch (error) {
        app.log.error(error);
        return reply.code(500).send({ error: 'Failed to cancel transaction' });
      }
    },
  );
}
