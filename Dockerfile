FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

RUN mkdir -p public/uploads logs

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "main.js"]