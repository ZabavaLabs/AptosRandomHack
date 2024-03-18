FROM node:16-buster
RUN mkdir /app
COPY package.json /app/
WORKDIR /app
COPY . ./

RUN pnpm install
RUN pnpm run build
EXPOSE 8080
CMD ["pnpm", "run", "dev"]
