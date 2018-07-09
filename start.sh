
#!/bin/bash

#INTERFACES

contiene () {
	local n=$#
	local value=${!n}
	for ((i=1;i < $#;i++)) {
		if [ "${!i}" == "${value}" ]; then 
			echo "y"
			return 0
		fi
	}
	echo "n"
	return 1
}

getinfo(){

routerip=`dialog --stdout --title "ip de router" --inputbox "digita la ip de tu routerer" 0 0 192.168.0.1`
netmask=`dialog --stdout --title "mascara de red" --inputbox "digita mascara de red" 0 0 255.255.255.0`
staticip=`dialog --stdout --title "ip de servidor" --inputbox "digita la ip a asignar al servidor" 0 0 192.168.0.100`
echo "IP DE ROUTER:     " $routerip
echo "MASCARA DE RED:    "$netmask
echo "IP PARA SERVIDOR: " $staticip
if validar_ip $staticip;
	then echo "IP correcta";
	else echo "no es una IP valida"
fi
}

validar_ip(){
echo "$staticip"
local ip=$staticip
local start=1
   if [[ $ip =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	OIFS=$IFS
	IFS='.'
	ip=($ip)
	IFS=$OIFS
	[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
	start=$?
   fi 
return $start
}

writeinterfacefile(){
cat << EOF > $1
#loopback
auto lo
iface lo inet loopback
#interface primaria puente
auto $puente
iface $puente inet dhcp
#interfaz de red interna 
auto $interna
iface $interna inet static
   address $staticip
   netmask $netmask
   gateway $routerip
EOF
touch /tmp/ipserver
echo $staticip > /tmp/ipserver
touch /tmp/interfazserver
touch /tmp/iproute
echo $interna > /tmp/interfazserver
echo $routerip > /tmp/iproute
echo ""
echo "su informacion de ha guardado en '$1' "
echo ""
cat /etc/network/interfaces
ifconfig $interna donw
ifconfig $interna up
dhclient -r
dhclient -v $puente
/etc/init.d/networking stop
/etc/init.d/networking start

#configurando NAT
touch route.sh
echo "#!/bin/bash" > /home/route.sh
echo 'echo "1" >/proc/sys/net/ipv4/ip_forward' >> /home/route.sh
echo "iptables -t nat -A POSTROUTING -o $puente -j MASQUERADE" >>/home/route.sh
echo "iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISH -j ACCEPT" >>/home/route.sh
echo "iptables -A FORWARD -i $interna -o $puente -j ACCEPT" >> /home/route.sh
#fin de NAT
#DNS google
echo "nameserver 8.8.8.8" > /etc/resolv.conf
#agregar al inicio del crontab
reb=$(grep "route.sh" /etc/crontab)
if [ -z "$reb" ]; then
	echo "@reboot    root    bash  /home/route.sh" >> /etc/crontab
fi
#fin crontab

#ejecutar scripts


chmod +x repos.sh
./repos.sh

chmod +x epoptes.sh
./epoptes.sh

chmod +x apache.sh
./apache.sh

chmod +x mysql.sh
./mysql.sh

chmod +x sed.sh
./sed.sh

chmod +x dnsmasq.sh
./dnsmasq.sh

chmod +x samba.sh
./samba.sh

chmod +x /home/route.sh
sh /home/route.sh

chmod +x squid.sh
./squid.sh

chmod +x ftp.sh
./ftp.sh

#fin de ejecucion de scripts

exit 0
}

file="/etc/network/interfaces"
if [ ! -f $file ]; then
	echo ""
	echo "el '$file' no existe"
	read -p "Desea crear el archivo? [s/n]:" sn
	case $sn in
		[Ss]* ) touch /etc/network/interfaces;;
		[Nn]* ) exit 1;;
	esac
fi

echo "Configurando:"
echo "Tarjetas de RED:"
touch /tmp/tarjetas
ip link show|grep ^[0-9]|grep -v lo|cut -f2 -d":" > /tmp/tarjetas

x=0
for i in $(cat /tmp/tarjetas) 
do
occiones[$x]=$i
x=$x+1
done
#SELECCIONANDO LA INTEFACE INTERNA
dialog --menu "seleccione tarjeta de red interna:" 0 0 0 1 "${occiones[0]}" 2 "${occiones[1]}" 2> /tmp/red.tmp.$$
x=$(cat /tmp/red.tmp.$$)-1
interna=${occiones[$x]}
if [ $interna = ${occiones[0]} ]
then
	puente=${occiones[1]}
else
	puente=${occiones[0]}
fi
rm /tmp/red.tmp.$$


getinfo;
echo ""

while true; do
read -p "Esta informacion es correcta? [s/n]: " sn
   case $sn in
	[Ss]* ) writeinterfacefile $file;;
	[Nn]* ) getinfo;;
	    * ) echo "Responda  S o N!";;
   esac
done

