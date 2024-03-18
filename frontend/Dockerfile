FROM node:20-alpine
WORKDIR /app
COPY . ./

RUN npm install -g pnpm
RUN pnpm install
RUN pnpm deploy:example

WORKDIR /app/apps/nextjs-example
RUN pnpm install
RUN pnpm run build

EXPOSE 8080

CMD ["pnpm", "run", "start"]
