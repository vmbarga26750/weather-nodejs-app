FROM quay.io/ibmgaragecloud/node:lts-stretch as build
WORKDIR /app
COPY . .
RUN npm install
RUN npm ci
EXPOSE 8080
CMD [ "npm", "start" ]
