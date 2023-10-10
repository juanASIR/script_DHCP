#!/bin/bash
# Script

# Actualizamos paquetes
sudo apt update

# Actualizamos paquetes instalados
sudo apt upgrade

# Instalamos isc-server-dhcp
sudo apt install isc-server-dhcp

# Configuramos la ruta /etc/default/isc-server-dhcp
nano /etc/default/isc-server-dhcp
