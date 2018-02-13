#CloudXNS DDNS with BashShell
#Github:https://github.com/lixuy/CloudXNS-DDNS-with-BashShell
#More: https://03k.org/cloudxns-ddns-with-bashshell.html
#CONF START
API_KEY="abcdefghijklmnopqrstuvwxyz1234567"
SECRET_KEY="abcdefghijk12345"
DOMAIN="home.xxxx.com"
CHECKURL="http://ip.qq.com"
#OUT="pppoe0"
#CONF END
APIURL="http://www.cloudxns.net/api2/ddns"
JSON="{\"domain\":\"$DOMAIN\"}"
NOWTIME=$(env LANG=en_US.UTF-8 date +'%a %h %d %H:%M:%S %Y')
HMAC=$(echo -n $API_KEY$APIURL$JSON$NOWTIME$SECRET_KEY|md5sum|cut -d' ' -f1)

date
if (echo $CHECKURL |grep -q "://");then
IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
URLIP=$(curl $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s $CHECKURL|grep -Eo "$IPREX"|tail -n1)
echo "[URL IP]:$URLIP"
dnscmd="nslookup";type nslookup >/dev/null 2>&1||dnscmd="ping -c1"
DNSIP=$($dnscmd $DOMAIN|grep -Eo "$IPREX"|tail -n1)
echo "[DNS IP]:$DNSIP"
if [ "$DNSIP" == "$URLIP" ];then
echo "IP SAME IN DNS,SKIP UPDATE."
exit
fi
fi
POST=$(curl $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -k -s $APIURL -X POST -d $JSON -H "API-KEY: $API_KEY" -H "API-REQUEST-DATE: $NOWTIME" -H "API-HMAC: $HMAC" -H 'Content-Type: application/json')
if (echo $POST |grep -q "success");then
echo "API UPDATE DDNS SUCCESS $URLIP"
else echo "Error: $POST"
fi
