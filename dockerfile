FROM node:20.14.0-alpine3.20 as base
RUN npm i -g pnpm

FROM base as build
WORKDIR /root/app
COPY package.json .

RUN ["pnpm", "install"]

COPY . .
RUN npx tsdx build \
    && npx prisma generate

EXPOSE 80
CMD ["node", "dist/index.js"]