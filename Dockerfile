FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force


FROM node:20-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# The runtime container runs with node directly, so npm/npx are not needed.
# Removing npm reduces the image attack surface and avoids shipping package-manager vulnerabilities.
RUN addgroup -S nodejs \
    && adduser -S appuser -G nodejs \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx \
    && rm -rf /root/.npm

COPY --from=deps --chown=appuser:nodejs /app/node_modules ./node_modules

COPY --chown=appuser:nodejs main.js ./
COPY --chown=appuser:nodejs controllers ./controllers
COPY --chown=appuser:nodejs models ./models
COPY --chown=appuser:nodejs routes ./routes
COPY --chown=appuser:nodejs services ./services
COPY --chown=appuser:nodejs validators ./validators
COPY --chown=appuser:nodejs views ./views
COPY --chown=appuser:nodejs public ./public

RUN mkdir -p public/uploads logs \
    && chown -R appuser:nodejs /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "main.js"]