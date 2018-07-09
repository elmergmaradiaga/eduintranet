#!/bin/bash
app=$"mysql-server"
app2=$"phpmyadmin"
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
	apt install -y $app2
fi
sed -i "s/create database xoolar;/grant all privileges on xoolar.* to xoolar;/g" /var/www/html/schema.sql
echo -e "create database xoolar;\n$(cat /var/www/html/schema.sql )" > /var/www/html/schema.sql
echo -e "create user 'xoolar' identified by 'xoolar';\n$(cat /var/www/html/schema.sql )" > /var/www/html/schema.sql
mysql < /var/www/html/schema.sql;


