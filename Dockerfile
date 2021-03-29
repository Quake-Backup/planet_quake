FROM debian:bullseye-slim AS builder

RUN \
  echo "# INSTALL DEPENDENCIES ##########################################" && \
  apt-get update && \
  apt upgrade -y && apt dist-upgrade && \
  apt-get install -y build-essential "linux-headers-*-common" libcurl4-gnutls-dev curl g++ gcc git make nodejs npm python3 python3-distutils vim && \
  mkdir -p /tmp/build
RUN \
  echo "# FETCH INSTALLATION FILES ######################################" && \
  cd /tmp/build && \
  git clone --recursive --progress https://github.com/briancullinan/planet_quake && \
  cd /tmp/build/planet_quake && \
  git submodule add -f git://github.com/emscripten-core/emsdk.git code/xquakejs/lib/emsdk && \
  git submodule update --init --recursive --progress && \
  /tmp/build/planet_quake/code/xquakejs/lib/emsdk/emsdk install latest-upstream
RUN \
  echo "# BUILD NATIVE SERVER ##########################################" && \
  cd /tmp/build/planet_quake && \
  make clean release BUILD_CLIENT=0 NOFPU=1
RUN \
  echo "# BUILD JS CLIENT ##########################################" && \
  cd /tmp/build/planet_quake && \
  npm install && \
  npm run install:emsdk && \
  echo "" >>  /root/.emscripten && \
  echo "BINARYEN_ROOT = '/tmp/build/planet_quake/code/xquakejs/lib/emsdk/upstream'" >> /root/.emscripten && \
  echo "LLVM_ROOT = '/tmp/build/planet_quake/code/xquakejs/lib/emsdk/upstream/bin'" >> /root/.emscripten && \
  echo "NODE_JS = '/usr/bin/node'" >> /root/.emscripten && \
  echo "EM_CACHE = '/tmp/build/planet_quake/code/xquakejs/lib/emsdk/cache'" >> /root/.emscripten && \
  mkdir /tmp/build/planet_quake/code/xquakejs/lib/emsdk/cache && \
  export EM_CACHE=/tmp/build/planet_quake/code/xquakejs/lib/emsdk/cache && \
  export EMSCRIPTEN_CACHE=/tmp/build/planet_quake/code/xquakejs/lib/emsdk/cache && \
  /usr/bin/python3 ./code/xquakejs/lib/emsdk/upstream/emscripten/embuilder.py build sdl2 vorbis ogg zlib && \
  export STANDALONE=1 && \
  make clean release PLATFORM=js
RUN \
  echo "# COPY OUTPUT ##########################################" && \
  mkdir ~/planet_quake && \
  mkdir ~/quakejs && \
  mkdir ~/quakejs/bin && \
  mkdir ~/quakejs/lib && \
  rm -R /tmp/build/planet_quake/code/xquakejs/lib/emsdk && \
  cp -R /tmp/build/planet_quake/code/xquakejs/bin/* ~/quakejs/bin && \
  cp -R /tmp/build/planet_quake/code/xquakejs/lib/* ~/quakejs/lib && \
  cp /tmp/build/planet_quake/package.json ~/quakejs && \
  cp /tmp/build/planet_quake/build/release-js-js/quake3e.* ~/quakejs/bin && \
  cp /tmp/build/planet_quake/build/release-linux-x86_64/quake3e.ded.x64 ~/planet_quake

#  cp /home/ioq3srv/planet_quake/quakejs/bin/q3eded.service /etc/systemd/system && \
FROM node:12.15-slim AS server
COPY --from=builder /root/planet_quake /home/ioq3srv/planet_quake
COPY --from=builder /root/quakejs /home/ioq3srv/quakejs
RUN \
  apt-get update && \
  apt-get install -y systemd imagemagick imagemagick-common vorbis-tools vim python && \
  useradd ioq3srv && \
  mkdir /home/ioq3srv/baseq3 && \
  sed -i -e 's/code\/xquakejs\///g' /home/ioq3srv/quakejs/package.json && \
  cp /home/ioq3srv/quakejs/bin/http.service /etc/systemd/system && \
  cp /home/ioq3srv/quakejs/bin/proxy.service /etc/systemd/system && \
  cd /home/ioq3srv/quakejs && \
  npm install && \
  npm install --only=dev && \
  chmod a+x /home/ioq3srv/quakejs/bin/start.sh && \
  chown -R ioq3srv /home/ioq3srv
USER ioq3srv
EXPOSE 27960/udp
EXPOSE 1081/tcp
EXPOSE 8080/tcp
VOLUME [ "/tmp/baseq3" ]
VOLUME [ "/tmp/planet_quake" ]
VOLUME [ "/tmp/quakejs" ]
ENV RCON=password123!
ENV GAME=baseq3-cc
ENV BASEGAME=baseq3-cc
CMD ["/home/ioq3srv/quakejs/bin/start.sh"]
