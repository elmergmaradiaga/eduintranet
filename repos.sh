#!/bin/bash

#SOURCES.LIST
echo "CONFIGURANDO REPOSITORIOS...."

echo "deb http://deb.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list

echo "deb http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list

echo "deb http://security.debian.org/debian-security/ stretch/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/debian-security/ stretch/updates main contrib non-free" >> /etc/apt/sources.list

echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list

cat /etc/apt/sources.list

apt update
