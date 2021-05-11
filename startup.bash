#!/bin/bash

if [[ -z "${DKIM_DOMAIN1}" ]] || [[ -z "${DKIM_SELECTOR1}" ]]; then
    echo "Please set DKIM_DOMAIN and DKIM_SELECTOR environment variables."
    exit 1
fi

echo -e "\e[32mDKIM_* variables:\e[39m"
echo -e "   DKIM_DOMAIN1 = ${DKIM_DOMAIN1}"
echo -e "   DKIM_SELECTOR1 = ${DKIM_SELECTOR1}"
echo -e "   DKIM_DOMAIN2 = ${DKIM_DOMAIN2}"
echo -e "   DKIM_SELECTOR2 = ${DKIM_SELECTOR2}"
echo

if [[ ! -f "/etc/opendkim/keys/${DKIM_SELECTOR1}.private" ]]; then
    echo -e "\e[32mNo opendkim key found; generation new one ...\e[39m"
    opendkim-genkey \
        -b 1024 \
        -d ${DKIM_DOMAIN1} \
        -D /etc/opendkim/keys \
        -h sha256 \
        -r \
        -s ${DKIM_SELECTOR1} \
        -v
    echo

    echo -e "\e[32mSet DNS setting to:\e[39m"
    cat /etc/opendkim/keys/${DKIM_SELECTOR1}.txt
    echo
    echo -e "\e[32mNo opendkim key found; generation new one ...\e[39m"
    opendkim-genkey \
        -b 1024 \
        -d ${DKIM_DOMAIN2} \
        -D /etc/opendkim/keys \
        -h sha256 \
        -r \
        -s ${DKIM_SELECTOR2} \
        -v
    echo

    echo -e "\e[32mSet DNS setting to:\e[39m"
    cat /etc/opendkim/keys/${DKIM_SELECTOR2}.txt
    echo
fi

echo -e "\e[32mReplacing:\e[39m"
cat /etc/opendkim/*Table
echo -e "\e[32mto:\e[39m"
sed -i -- "s/{{DKIM_DOMAIN1}}/${DKIM_DOMAIN1}/g" /etc/opendkim/*Table
sed -i -- "s/{{DKIM_SELECTOR1}}/${DKIM_SELECTOR1}/g" /etc/opendkim/*Table
sed -i -- "s/{{DKIM_DOMAIN2}}/${DKIM_DOMAIN2}/g" /etc/opendkim/*Table
sed -i -- "s/{{DKIM_SELECTOR2}}/${DKIM_SELECTOR2}/g" /etc/opendkim/*Table
cat /etc/opendkim/*Table
echo

chown -R opendkim:opendkim /etc/opendkim
chmod -R 0700 /etc/opendkim/keys

/usr/bin/supervisord -c /etc/supervisor.conf

echo -e "\e[32mTailing /var/log/maillog ...\e[39m"
postmap /etc/postfix/aliases
postmap /etc/postfix/sender_transports
touch /var/log/mail.log
tail -F /var/log/mail.log
