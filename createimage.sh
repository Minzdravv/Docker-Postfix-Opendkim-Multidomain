docker build -t postfix:latest . < Dockerfile
docker run -d -e DKIM_DOMAIN1=benequire.ru -e DKIM_SELECTOR1=test2 -e DKIM_DOMAIN2=loqui.ru -e DKIM_SELECTOR2=test3 -p 25:25 postfix:latest