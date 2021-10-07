## From latest Alpine Base image
FROM alpine:latest

## Install NPM
RUN apk add --no-cache npm

WORKDIR /app
## Copy local content to image
COPY . .

## Install nodejs app
RUN npm install

## Run Test
RUN npm ci

## Exposes the listening port of the application
EXPOSE 8080

# Run App
CMD [ "npm", "start" ]
