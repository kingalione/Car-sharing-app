FROM node:lts-alpine
WORKDIR /app
COPY package*.json ./
RUN yarn global add typescript
RUN yarn global add @vue/cli
RUN yarn global add serve
RUN yarn add vuetify
RUN yarn install
COPY . ./
RUN yarn build


FROM nginx:stable-alpine as production-stage
COPY /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]