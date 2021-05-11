FROM alpine:latest
LABEL Maintainer="Minzdrav <minzdravv@gmail.com>"
LABEL Description="This image is used to start postfix, opendkim, TLS and multidomain."
# update / upgrade / add

RUN \
	apk update --no-cache && \
	apk upgrade --no-cache && \
	apk add --no-cache rsyslog bash supervisor postfix opendkim opendkim-utils nano mc

# postfix
WORKDIR /
#ADD postfixbenequire.pem /etc/postfix/ssl/
ADD conf/postfix.conf /etc/postfix/main-override.cf
ADD conf/master.conf /etc/postfix/main-master.cf
RUN \
	cd /etc/postfix && \
	cat main.cf main-override.cf > main-sum.cf && \
	mv main-sum.cf main.cf && \
	cat master.cf main-master.cf > master-sum.cf && \
	mv master-sum.cf master.cf && \
	rm main-override.cf && \
	rm main-master.cf

# openkim
ADD opendkim/ /etc/opendkim/
RUN mkdir /etc/opendkim/keys

# supervisor
ADD conf/supervisord.conf /etc/supervisor.conf
ADD supervisor-script/ /etc/supervisor-script/
RUN chmod +x /etc/supervisor-script/*.sh

# startup
ADD startup.bash /startup.bash
ADD conf/sender_transports /etc/postfix/sender_transports
RUN chmod +x /*.bash
CMD ["/startup.bash"]

EXPOSE 25