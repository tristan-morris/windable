FROM node:8-buster

ADD ./package.json /opt/wind/

WORKDIR /opt/wind

RUN npm install

RUN npm link grunt-cli

ADD ./ /opt/wind/

CMD grunt app