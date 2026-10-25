FROM node:24-alpine AS build
LABEL author="Žiga Slatnar Štagar"

WORKDIR /app
COPY package.json .npmrc ./
RUN npm i
COPY . ./
RUN npm run build

FROM node:24-alpine

WORKDIR /app
COPY --from=build /app/.output ./
ENV PORT=80
ENV HOST=0.0.0.0

EXPOSE 80

CMD ["node", "/app/server/index.mjs"]