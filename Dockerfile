FROM node:lts-alpine
WORKDIR /app
COPY package*.json ./
RUN yarn global add typescript
RUN yarn global add @vue/cli
RUN yarn global add serve
RUN yarn add vuetify
RUN yarn install
COPY . ./
CMD ["yarn", "serve"]