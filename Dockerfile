FROM rawmind/alpine-base:0.3.3-2
MAINTAINER Raul Sanchez <rawmind@gmail.com>

# Compile and install monit and confd
ENV MONIT_VERSION=5.16 \
    MONIT_HOME=/opt/monit
ENV PATH $PATH:${MONIT_HOME}/bin

# Compile and install monit
RUN apk add --update gcc musl-dev make openssl-dev \
  && mkdir -p /opt/src; cd /opt/src ${MONIT_HOME}/etc/conf.d ${MONIT_HOME}/log \
  && curl -sS https://mmonit.com/monit/dist/monit-${MONIT_VERSION}.tar.gz | gunzip -c - | tar -xf - \
  && cd /opt/src/monit-${MONIT_VERSION} \
  && ./configure  --prefix=${MONIT_HOME} --without-pam \
  && make && make install \
  && apk del gcc musl-dev make openssl-dev \
  && rm -rf /var/cache/apk/* /opt/src 
COPY monit/monitrc ${MONIT_HOME}/etc/monitrc
RUN chown root:root ${MONIT_HOME}/etc/monitrc && chmod 700 ${MONIT_HOME}/etc/monitrc
COPY monit/basic ${MONIT_HOME}/etc/conf.d/basic

ENTRYPOINT ["${MONIT_HOME}/bin/monit","-I"]
