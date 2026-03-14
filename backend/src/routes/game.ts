import { FastifyInstance } from 'fastify';

type MlLookupBody = {
  userId?: string;
  zoneId?: string;
};

function isNumeric(value: string): boolean {
  return /^\d+$/.test(value);
}

function buildMockNickname(userId: string, zoneId: string): string {
  const suffix = (Number(userId) + Number(zoneId)) % 999;
  return `ML_Player_${suffix.toString().padStart(3, '0')}`;
}

export async function gameRoutes(app: FastifyInstance) {
  app.post('/mobile-legends/lookup', async (request, reply) => {
    const { userId, zoneId } = request.body as MlLookupBody;

    if (!userId || !zoneId) {
      return reply.code(400).send({
        error: 'userId and zoneId are required',
      });
    }

    if (!isNumeric(userId) || !isNumeric(zoneId)) {
      return reply.code(400).send({
        error: 'userId and zoneId must be numeric',
      });
    }

    // Provider integration is not added yet. This endpoint keeps lookup logic
    // centralized in backend, so provider API can be plugged in later.
    const nickname = buildMockNickname(userId, zoneId);

    return reply.send({
      valid: true,
      game: 'mobile_legends',
      userId,
      zoneId,
      nickname,
      source: 'mock',
    });
  });
}
