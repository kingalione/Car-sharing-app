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


# production environment
FROM nginx:1.16.0-alpine
COPY ./dist /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]