FROM node:20-alpine

COPY . ./

RUN npm install -g pnpm
RUN pnpm install
RUN pnpm deploy:example

WORKDIR /apps/nextjs-example
RUN pnpm install
RUN pnpm run build

EXPOSE 8080

CMD ["pnpm", "run", "start"]
