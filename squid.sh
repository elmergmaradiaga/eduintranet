#!/bin/bash


#SQUID
app=$"squid"
function instalado() {
aux=$(aptitude show $app | grep "Estado: instalado")
if `echo "$aux" | grep "Estado: instalado" >/dev/null`
then
	return 1
else
	return 0
fi
}
instalado $1 &> /dev/null
if [ "$?" = "1" ]
then
	echo $app ya esta instalado
else 
	apt install -y $app
fi
info() {
	cachem=$(grep "#cache_mem 256 MB" /etc/squid/squid.conf)
	if [ -z "$cachem" ]; then
		echo "cache_mem 256 MB" >> /etc/squid/squid.conf
	fi
	cached=$(grep "cache_dir ufs /var/spool/squid 1000 16 256" /etc/squid/squid.conf)
	if [ -z "$cached" ]; then
		echo "cache_dir ufs /var/spool/squid 1000 16 256" >> /etc/squid/squid.conf
	fi
	iproute=$(cat /tmp/iproute)
	red=$(cut -f1,2,3 -d"."<<<$iproute)
	port=$(grep "http_port 3128" /etc/squid/squid.conf)
	acl1=$(grep "acl redglobal src $red.0" /etc/squid/squid.conf)
	acl2=$(grep "acl redlocal" /etc/squid/squid.conf)
	acl3=$(grep "acl denegados" /etc/squid/squid.conf)
	access=$(grep "http_access allow redglobal" /etc/squid/squid.conf)
	access1=$(grep "http_access allow redlocal" /etc/squid/squid.conf)
	if [ -z "$port" ]; then
		echo "http_port 3128" >> /etc/squid/squid.conf
	fi
	if [ -z "$acl1" ]; then
		echo "#CONTROL DE ACCESO" >> /etc/squid/squid.conf
		echo "acl redglobal src $red.0" >> /etc/squid/squid.conf
	fi
	if [ -z "$acl2" ]; then
		echo "acl redlocal src '/etc/squid/redlocal'" >> /etc/squid/squid.conf
	fi
	if [ -z "$acl3" ]; then
		echo "acl denegados url_regex '/etc/squid/denegados'" >> /etc/squid/squid.conf
	fi
	if [ -z "$access" ]; then
		echo "" >> /etc/squid/squid.conf
		echo "#HTTP ACCESS" >> /etc/squid/squid.conf
		echo "http_access allow redglobal" >> /etc/squid/squid.conf
	fi
	if [ -z "$access1" ]; then
		echo "http_access allow redlocal !denegados" >> /etc/squid/squid.conf
	tail -20 /etc/squid/squid.conf
	else
		echo "====== PROXY YA FUE CONFIGURADO ======"
  	fi
#configurando archivo de red local
	touch /etc/squid/redlocal
	ipserver=$(cat /tmp/ipserver)
	echo "$ipserver #ip de servidor" > /etc/squid/redlocal
	red=$(cut -f1,2,3 -d"."<<<$ipserver)
	for x in {200..250}
 	do
		echo $red.$x"/24" >> /etc/squid/redlocal
	done
#configuracion de sitios denegados 
echo ".facebook.com" > /etc/squid/denegados
echo "sex" >> /etc/squid/denegados
echo "xxx" >> /etc/squid/denegados
}

info;
/etc/init.d/squid stop
/etc/init.d/squid start
