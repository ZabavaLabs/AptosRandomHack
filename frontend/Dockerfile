FROM node:20-alpine

COPY . ./

RUN npm install -g pnpm
RUN pnpm install

WORKDIR /apps/nextjs-example

EXPOSE 8080

CMD ["pnpm", "run", "start"]
