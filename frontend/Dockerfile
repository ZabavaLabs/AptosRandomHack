FROM node:20-alpine

COPY . ./

RUN npm install -g pnpm
RUN pnpm install

EXPOSE 8080

RUN pnpm run my-deploy

WORKDIR /apps/nextjs-example/

CMD ["pnpm", "run", "start"]
