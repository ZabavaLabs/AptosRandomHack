FROM node:20-alpine

WORKDIR /project

COPY . ./

RUN npm install -g pnpm
RUN pnpm install

EXPOSE 8080

RUN pnpm run my-build

WORKDIR /project/apps/nextjs-example

CMD ["pnpm", "start"]
