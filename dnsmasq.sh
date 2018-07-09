#!/bin/bash

#DNSMASQ
app=$"dnsmasq"
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
#CONFIGURANDO DHCP
ipserver=$(cat /tmp/ipserver)
interface=$(cat /tmp/interfazserver)
rango=$(cut -f1,2,3 -d"."<<<$ipserver)
echo "interface=$interface" > /etc/dnsmasq.conf
echo "dhcp-range=$rango.200,$rango.250,12h" >> /etc/dnsmasq.conf
echo "dhcp-option=3,$ipserver" >> /etc/dnsmasq.conf
echo ""
echo "DHCP configurado correctamente"
#CONFIGURANDO HOST LOCAL
echo "$ipserver aula.lan" > /etc/hosts
tail -5 /etc/dnsmasq.conf
/etc/init.d/dnsmasq stop
/etc/init.d/dnsmasq start
