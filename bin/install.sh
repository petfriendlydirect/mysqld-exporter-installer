#!/bin/sh -e
VERSION=0.13.0
RELEASE=mysqld_exporter-${VERSION}.linux-amd64

_check_root () {
    if [ $(id -u) -ne 0 ]; then
        echo "Please run as root" >&2;
        exit 1;
    fi
}

_install_curl () {
    if [ -x "$(command -v curl)" ]; then
        return
    fi

    if [ -x "$(command -v apt-get)" ]; then
        apt-get update
        apt-get -y install curl
    elif [ -x "$(command -v yum)" ]; then
        yum -y install curl
    else
        echo "No known package manager found" >&2;
        exit 1;
    fi
}

_check_root
_install_curl

cd /tmp
curl -sSL https://github.com/prometheus/mysqld_exporter/releases/download/v${VERSION}/${RELEASE}.tar.gz | tar xz
mkdir -p /opt/mysqld_exporter
mv ${RELEASE}/mysqld_exporter /opt/mysqld_exporter/
rm -rf /tmp/${RELEASE}

mkdir -p /etc/mysqld_exporter
if [ ! -f /etc/mysqld_exporter/datasource ]; then
    echo "DATA_SOURCE_NAME=exporter:password@(localhost:3306)/" > /etc/mysqld_exporter/datasource
    echo "Please update /etc/mysqld_exporter/datasource with proper credentials"
fi

if [ -x "$(command -v systemctl)" ]; then
    cat << EOF > /lib/systemd/system/mysqld-exporter.service
[Unit]
Description=Prometheus agent
After=network.target
StartLimitIntervalSec=0

[Service]
EnvironmentFile=/etc/mysqld_exporter/datasource
Type=simple
Restart=always
RestartSec=1
ExecStart=/opt/mysqld_exporter/mysqld_exporter

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable mysqld-exporter
elif [ -x "$(command -v chckconfig)" ]; then
    cat << EOF >> /etc/inittab
::respawn:/opt/mysqld_exporter/mysqld_exporter
EOF
elif [ -x "$(command -v initctl)" ]; then
    cat << EOF > /etc/init/mysqld-exporter.conf
start on runlevel [23456]
stop on runlevel [016]
exec /opt/mysqld_exporter/mysqld_exporter
respawn
EOF

    initctl reload-configuration
    stop mysqld-exporter || true
else
    echo "No known service management found" >&2;
    exit 1;
fi
