FROM node:20-alpine

WORKDIR /project

COPY . ./

RUN npm install -g pnpm
RUN pnpm install

EXPOSE 8080

# RUN pnpm run my-deploy

WORKDIR /project/apps/nextjs-example

RUN pnpm build

RUN pnpm export

CMD ["pnpm", "run", "start"]
