FROM node:20.14.0-alpine3.20

WORKDIR /root/app
COPY package.json .

RUN ["npm", "install"]

COPY . .
RUN npx tsdx build \
    && npx prisma generate

EXPOSE 80
CMD ["node", "dist/index.js"]