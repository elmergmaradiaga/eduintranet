#!/bin/bash
app=$"samba"
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
	apt -y install $app
	mkdir /var/archivos
	chmod 777 /var/archivos
fi

#SAMBA
smb() {
	sed -i "s/security=USER/security=SHARE/g" /etc/samba/smb.conf
	smb=$(grep "ULS" /etc/samba/smb.conf)
	if [ -z "$smb" ]; then
		echo "====== CONFIGURANDO AREA PUBLICA SAMBA ======"
		echo -e "\n
[ULS] \n
   comment= ULS Folder \n
   path= /var/archivos \n
   public= yes \n
   writable= yes \n
   create mask= 0777 \n
   directory mask= 0777 \n
   force user= nobody \n
   force group= nogroup \n
   guest ok= yes" >> /etc/samba/smb.conf
else
	echo "====== AREA PUBLICA YA FUE CONFIGURADA ======"
  fi
}

smb;
/etc/init.d/samba stop
/etc/init.d/samba start
