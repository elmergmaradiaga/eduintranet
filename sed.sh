#!/bin/bash


#SED
app=$"sed"
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
	apt install $app
fi
