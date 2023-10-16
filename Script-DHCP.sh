#!/bin/bash

# Actualizar la lista de paquetes disponibles
sudo apt update

# Actualizar todos los paquetes instalados
sudo apt upgrade -y

# Instalar el servicio isc-dhcp-server
sudo apt install isc-dhcp-server -y

# Cambiar la configuración en /etc/default/isc-dhcp-server
sudo bash -c 'cat << EOF > /etc/default/isc-dhcp-server
# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
# Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACESv4="enp0s3"
INTERFACESv6=""
EOF'

# Cambiar la configuración en /etc/dhcp/dhcpd.conf
sudo bash -c 'cat << EOF > /etc/dhcp/dhcpd.conf
# dhcpd.conf

option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

authoritative;
failover peer "FAILOVER" {
  primary;
  address 192.168.1.2;
  port 647;
  peer address 192.168.1.3;
  peer port 647;
  max-unacked-updates 10;
  max-response-delay 30;
  load balance max seconds 3;
  mclt 1800;
  split 128;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
  option broadcast-address 192.168.1.255;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  pool {
    failover peer "FAILOVER";
    max-lease-time 3600;
    range 192.168.1.10 192.168.1.20;
  }
}
EOF'

# Cambiar la configuración en /etc/network/interfaces
sudo bash -c 'cat << EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto enp0s3
iface enp0s3 inet static
        address 192.168.1.2
        netmask 255.255.255.0
        network 192.168.1.0
        broadcast 192.168.1.255

auto enp0s8
iface enp0s8 inet dhcp
EOF'

# Reiniciar el servicio networking
sudo systemctl restart networking

# Reiniciar el servicio dhcp
sudo systemctl restart isc-dhcp-server

# Mostrar un mensaje de finalización
echo "Actualización de paquetes y configuración completada, networking reiniciado."
