#!/bin/bash

#DNSMASQ
app=$"epoptes"
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
#CONFIGURANDO EPOPTES
usuario=`dialog --stdout --title "agregar usuario a grupo epoptes" --inputbox "digita el nombre de usuario" 0 0 elmer`
gpasswd -a $usuario epoptes
#CREANDO SCRIPT PARA CLIENTES
ipserver=$(cat /tmp/ipserver)
touch /home/$usuario/epoclient.sh
echo "#!/bin/bash" >/home/$usuario/epoclient.sh
echo "apt install epoptes-client" >>/home/$usuario/epoclient.sh
echo "SERVER="$ipserver" >> /etc/default/epoptes-client" >>/home/$usuario/epoclient.sh
echo "epoptes-client -c" >>/home/$usuario/epoclient.sh
echo "reboot" >>/home/$usuario/epoclient.sh
chmod +x /home/$usuario/epoclient.sh
