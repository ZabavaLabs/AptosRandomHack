FROM node:20-alpine

COPY . ./

RUN npm install -g pnpm
RUN pnpm install

EXPOSE 8080

CMD ["pnpm", "run", "deploy:example"]
