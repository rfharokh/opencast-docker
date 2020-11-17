#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM maven:3.6-jdk-8-slim AS build

ARG repo="https://github.com/rfharokh/opencast-8.6"
ARG branch="8.x"

ENV OPENCAST_DISTRIBUTION="admin" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}" \
    FFMPEG_VERSION="20200316042902-N-96975-gc467328f07"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tar gzip bzip2 xz-utils git \
      ca-certificates openssl \
      make gcc g++ libc-dev lsof \
  \
 && git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
 && cd /tmp/su-exec \
 && make \
 && cp su-exec /usr/local/sbin \
  \
 && mkdir -p /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://pkg.opencast.org/bin/ffmpeg/ffmpeg-${FFMPEG_VERSION}.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /usr/local/bin \
  \
 && groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \ 
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
  \
 && cd \
 && rm -rf /tmp/* /var/lib/apt/lists/*

USER "${OPENCAST_USER}"

RUN git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
 && mvn --batch-mode install \
      -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
      -DskipTests=true \
      -Dcheckstyle.skip=true \
      -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}"/* ~/.m2 ~/.npm ~/.node-gyp

FROM openjdk:8-jdk-slim-stretch
LABEL maintainer="RFH Köln" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="8.6" \
      org.label-schema.name="opencast-admin" \
      org.label-schema.description="Docker image for the Opencast admin distribution" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vendor="RFH Köln" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER sh" \
      org.label-schema.docker.cmd.help="docker run --rm quay.io/opencast/admin:8.6 app:help"

ENV OPENCAST_VERSION="8.6" \
    OPENCAST_DISTRIBUTION="admin" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="root" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc"

RUN useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}"

COPY --from=build /usr/local/sbin/su-exec /usr/local/sbin/su-exec
COPY --from=build /usr/local/bin/ff* /usr/local/sbin/
COPY --chown=opencast:root --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY --chown=opencast:root assets/scripts "${OPENCAST_SCRIPTS}"
COPY --chown=opencast:root assets/support "${OPENCAST_SUPPORT}"
COPY --chown=opencast:root assets/etc/* "${OPENCAST_CONFIG}/"
COPY assets/docker-entrypoint.sh assets/docker-healthcheck.sh /
RUN chmod +w /docker-entrypoint.sh
RUN chmod 777 "${OPENCAST_CONFIG}/"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates openssl tzdata curl jq \
      fontconfig fonts-dejavu fonts-freefont-ttf fonts-liberation fonts-linuxlibertine \
      hunspell hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-us hunspell-en-za \
      tesseract-ocr tesseract-ocr-eng \
      sox synfig \
      nfs-common netcat-openbsd \
      lsof \
 && javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && rm -rf /tmp/* /var/lib/apt/lists/* "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
