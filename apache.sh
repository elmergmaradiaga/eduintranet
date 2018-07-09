#!/bin/bash


#APACHE2
app=$"apache2"
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
	apt install -y php-common libapache2-mod-php php-cli
fi

#DIRECTORIO CON SISTEMA DE GESTION DE NOTAS
if [ -d /var/www/html/xolar ];
then
	echo "El directorio ya existe"
else
	echo "instalando sistema de notas xoolar"
	archivo=$"master.zip"
	if [ ! -f $archivo ]
	then
		wget https://github.com/evilnapsis/xoolar-lite/archive/master.zip
	fi
	unzip master
	mv xoolar-lite-master/* /var/www/html
fi

echo "<?php" >/var/www/html/core/controller/Database.php
echo "class Database {" >>/var/www/html/core/controller/Database.php
echo "	public static "'$db'";" >>/var/www/html/core/controller/Database.php
echo "	public static "'$con'";" >>/var/www/html/core/controller/Database.php
echo "	function Database(){" >>/var/www/html/core/controller/Database.php
echo "		"'$this'"->user="xoolar";"'$this'"->pass="xoolar";"'$this'"->host="localhost";"'$this'"->ddbb="xoolar";" >>/var/www/html/core/controller/Database.php
echo "	}" >>/var/www/html/core/controller/Database.php

echo "	function connect(){" >>/var/www/html/core/controller/Database.php
echo "		"'$con'" = new mysqli("'$this'"->host,"'$this'"->user,"'$this'"->pass,"'$this'"->ddbb);" >>/var/www/html/core/controller/Database.php
echo "		return "'$con'";" >>/var/www/html/core/controller/Database.php
echo "	}" >>/var/www/html/core/controller/Database.php

echo "	public static function getCon(){" >>/var/www/html/core/controller/Database.php
echo "		if(self::"'$con'"==null && self::"'$db'"==null){" >>/var/www/html/core/controller/Database.php
echo "			self::"'$db'" = new Database();" >>/var/www/html/core/controller/Database.php
echo "			self::"'$con'" = self::"'$db'"->connect();" >>/var/www/html/core/controller/Database.php
echo "		}" >>/var/www/html/core/controller/Database.php
echo "		return self::"'$con'";" >>/var/www/html/core/controller/Database.php
echo "	}" >>/var/www/html/core/controller/Database.php
	
echo "}" >>/var/www/html/core/controller/Database.php
echo "?>" >>/var/www/html/core/controller/Database.php

chmod 777 -R /var/www/html/*
/etc/init.d/apache2 restart

