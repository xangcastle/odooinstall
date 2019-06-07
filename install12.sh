#!/bin/bash
#locale-gen es_NI.UTF-8
#dpkg-reconfigure locales
#Creamos el usuario y grupo de sistema 'odoo':
adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo
#Creamos en directorio en donde se almacenará el archivo de configuración y log de odoo::
mkdir /etc/odoo && mkdir /var/log/odoo/
# Instalamos Postgres y librerías base del sistema:
apt-get update && apt-get install postgresql build-essential python3-pil python3-lxml python-ldap3 python3-dev python3-pip python3-setuptools npm nodejs git gdebi libldap2-dev libsasl2-dev  libxml2-dev libxslt1-dev libjpeg-dev zlib libtiff-dev python3-pypdf2 libpq-dev -y
#Descargamos odoo version 11 desde git:
git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo/odoo
#Damos permiso al directorio que contiene los archivos de OdooERP  e instalamos las dependencias de python3 
chown odoo:odoo /opt/odoo/ -R && chown odoo:odoo /var/log/odoo/ -R && cd /opt/odoo/odoo && pip3 install -r requirements.txt
#Usamos npm, que es el gestor de paquetes Node.js para instalar less 
npm install -g less less-plugin-clean-css -y && ln -s /usr/bin/nodejs /usr/bin/node
#Descargamos dependencias e instalar wkhtmltopdf para generar PDF en odoo
apt install xfonts-base xfonts-75dpi -y
cd /tmp
wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
ln -s /usr/local/bin/wkhtmltopdf /usr/bin/
ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
#wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && gunzip GeoLiteCity.dat.gz && mkdir /usr/share/GeoIP/ && mv GeoLiteCity.dat /usr/share/GeoIP/
#Creamos un usuario 'odoo' para la base de datos:
su - postgres -c "createuser -s odoo"
#Creamos la configuracion de Odoo:
su - odoo -c "/opt/odoo/odoo/odoo-bin --addons-path=/opt/odoo/odoo/addons -s --stop-after-init"
#Creamos el archivo de configuracion de odoo:
mv /opt/odoo/.odoorc /etc/odoo/odoo.conf
#Agregamos los siguientes parámetros al archivo de configuración de odoo:
sed -i "s,^\(logfile = \).*,\1"/var/log/odoo/odoo-server.log"," /etc/odoo/odoo.conf
#sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo/odoo.conf
#sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo/odoo.conf
#Creamos el archivo de inicio del servicio de Odoo:
cp /opt/odoo/odoo/debian/init /etc/init.d/odoo && chmod +x /etc/init.d/odoo
ln -s /opt/odoo/odoo/odoo-bin /usr/bin/odoo
update-rc.d -f odoo start 20 2 3 4 5 .
service odoo start
