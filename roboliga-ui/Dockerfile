FROM node:24-alpine AS build
LABEL authors="zigas"

WORKDIR /app
COPY package.json .npmrc ./
RUN npm i
COPY . ./
RUN npm build

FROM node:24-alpine

WORKDIR /app
COPY --from=build /app/.output ./
ENV PORT=80
ENV HOST=0.0.0.0

EXPOSE 80

CMD ["node", "/app/server/index.mjs"]