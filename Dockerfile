FROM node:bullseye

COPY . /

RUN chmod +x entrypoint.sh

RUN apt update
RUN apt-get install -y jq
RUN yarn global add firebase-tools

ENTRYPOINT ["/entrypoint.sh"]
