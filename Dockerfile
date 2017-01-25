FROM alpine:3.4
MAINTAINER Antergos Developers

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 7.4.0

##
# Build & Install Node.js
##
RUN adduser -D -u 1000 node \
	&& apk add --no-cache libstdc++ bash \
	&& apk add --no-cache --virtual .build-deps \
		binutils-gold \
		curl \
		g++ \
		gcc \
		gnupg \
		libgcc \
		linux-headers \
		make \
		python \
		git \
		openssl \
	&& for key in \
		9554F04D7259F04124DE6B476D5A82AC7E37093B \
		94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
		0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
		FD3A5288F042B6850C66B31F09FE44734EB7990E \
		71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
		DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
		B9AE9905FFD7803F25714661B63B535A4C206CA9 \
		C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8; \
		do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c	\
	&& tar -xf "node-v$NODE_VERSION.tar.xz" \
	&& cd "node-v$NODE_VERSION" \
	&& ./configure \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install


##
# Build & Install NodeBB
##
RUN git clone https://github.com/nodebb/nodebb \
	&& ln -s /data/config.json /nodebb/config.json \
	&& cd nodebb \
	&& npm install \
	&& npm install \
		nodebb-plugin-dbsearch \
		nodebb-plugin-emoji-extended \
		nodebb-plugin-markdown \
		nodebb-plugin-registration-question \
		nodebb-plugin-soundpack-default \
		nodebb-plugin-spam-be-gone \
		nodebb-widget-essentials \
		nodebb-plugin-emailer-mailgun \
		nodebb-plugin-mentions \
		nodebb-plugin-question-and-answer \
		nodebb-plugin-composer-default \
		nodebb-plugin-imgur \
		nodebb-plugin-blog-comments \
		nodebb-plugin-gravatar \
		nodebb-plugin-ns-likes \
		nodebb-plugin-codeinput \
		nodebb-plugin-emoji-apple \
		nodebb-plugin-ns-login \
		nodebb-plugin-poll \
		nodebb-plugin-write-api \
		nodebb-plugin-emoji-static \
		nodebb-plugin-sso-auth0 \
		nodebb-plugin-topic-tags \
		nodebb-theme-antergos


##
# Remove Build Deps
##
RUN apk del .build-deps \
	&& rm -Rf "node-v$NODE_VERSION" \
	&& rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

ADD docker-entrypoint.sh /nodebb

ENV NODE_ENV production

WORKDIR /nodebb 

VOLUME ["/data"]

EXPOSE 4567
EXPOSE 8888

CMD [ "./docker-entrypoint.sh" ]
