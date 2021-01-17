# Runtime stage
FROM thies88/ubuntu-base-nginx

# Env vars
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

# Define install variables
ARG APT=""
ARG APT_DEPS="curl npm build-essential mongodb-org nodejs graphicsmagick"
ARG APP_REPO="deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu ${REL}/mongodb-org/4.0 multiverse"
ARG APP_LIST="mongodb-org-4.0.list"
ENV APP_DEBUGMODE=0
ARG DEBIAN_FRONTEND="noninteractive"

# Rocket Chat variables
ENV MONGO_URL=mongodb://localhost:27017/rocketchat?replicaSet=rs01 \
MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=rs01 \
ROOT_URL=http://127.0.0.1:3000 \
PORT=3000

# app start variables
ENV APP1="mongod -f /config/mongodb/mongod.conf"
ENV APP2="/usr/local/bin/node /app/Rocket.Chat/main.js"
#ENV APP3=""

RUN \
 echo "**** install application and needed packages ****" && \
 mkdir /usr/share/man/man1 && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
 echo ${APP_REPO} > /etc/apt/sources.list.d/${APP_LIST} && \
 #curl -o /tmp/repokey.key ${APP_REPOKEY} && apt-key add /tmp/repokey.key && \
 apt-get update && \
 apt-get install -y --no-install-recommends --no-install-suggests \
	${APT_DEPS} \
	${APT} && \
 echo "install deps" && \
 cd /tmp && \
 curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
 npm install -g inherits n && n 12.18.4 && \
 echo "**** install Rocket Chat ****" && \	
 curl -L https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz && \
 tar -xzf /tmp/rocket.chat.tgz -C /tmp && \
 cd /tmp/bundle/programs/server && npm install && npm update && \
 mv /tmp/bundle /app/Rocket.Chat && \
 #cd /app/Rocket.Chat/programs/server && npm update && \
echo "Config mongo" && \
sed -i "s/^#  engine:/  engine: mmapv1/"  /etc/mongod.conf && \
sed -i "s/^#replication:/replication:\n  replSetName: rs01/" /etc/mongod.conf && \
sed -i "s/dbPath: \/var\/lib\/mongodb/dbPath: \/config\/mongodb/g" /etc/mongod.conf && \
sed -i "s/path: \/var\/log\/mongodb\/mongod.log/path: \/config\/log\/mongodb\/mongod.log/g" /etc/mongod.conf && \
echo "**** cleanup ****" && \
apt-get autoremove -y --purge build-essential curl g++ make && \
#apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
npm cache clean --force && \
apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/cache/apt/* \
	/var/tmp/* \
	/var/log/* \
	/usr/share/doc/* \
	/usr/share/info/* \
	/var/cache/debconf/* \
	/usr/share/man/* \
	/usr/share/locale/*
	
# add local files
COPY root/ /

EXPOSE ${PORT}/tcp

ENTRYPOINT ["/init"]
