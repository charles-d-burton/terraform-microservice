#Use latest stable 6.x of NodeJS
FROM node:boron

#Create an unprivileged user to run the application in
#and make that the workspace
RUN useradd --user-group --create-home --shell /bin/false app
ENV HOME=/home/app
WORKDIR $HOME

#Copy in the application code
COPY package.json Procfile public server.js .eslintrc .babelrc .codeclimate.yml ./
COPY app/ ./app/
COPY config/ ./config/
COPY test/ ./test/
COPY .env.example .env

#Make the Node files owned by the unprivileged user
RUN chown -R app:app $HOME/*
#Install the application
RUN npm install --production
USER app

#Listnen on port 3000
EXPOSE 3000

CMD MONGOHQ_URL=mongodb://$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT node ./server.js
