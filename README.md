# Docker Postfix + Opendkim + Multidomin(SMTP)

```sh
docker run \
	d \
	-e DKIM_DOMAIN=example.com \
	-e DKIM_SELECTOR=mail \
	glavich/docker-postfix:latest
```



On container generation, DNS TXT setting will be dumped to logs. You can see it by typing: `docker logs CONTAINER_ID` (*for example `docker logs 5bcc4f4f186e` or `docker logs amazing_banach`*).
## Create container with private key

Add it to container folder: `/etc/opendkim/keys/`. Be sure to name it `SELECTOR.private` (*if selector is `mail`, then name file `mail.private`*).

```sh
docker run \
	-d \
	-e DKIM_DOMAIN=example.com \
	-e DKIM_SELECTOR=mail \
	-v $(pwd)/mail.private:/etc/opendkim/keys/mail.private \
	glavich/docker-postfix:latest
```

### Generate private key with opendkim-genkey

Add private key (*`mail.private`*) and dns txt setting (*`mail.txt`*)file.

```sh
docker run \
	--rm \
	-v $(pwd):/x \
	glavich/docker-postfix:latest \
	opendkim-genkey \
		-b 1024 \
		-d example.com \
		-D /x \
		-h sha256 \
		-r \
		-s mail \
		-v
```
###Multidomin
Add all your domains to file /conf/sender_transports and /conf/master.
Add new TXT dns settings, if you need opendkim.
