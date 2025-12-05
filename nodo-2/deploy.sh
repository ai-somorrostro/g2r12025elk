#!/bin/bash
set -e

# Script de deployment para ELK Stack
# Copia configuraciones desde elk-configs a los directorios de instalación

ELK_HOME="/home/g2/ELK"
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/elk-configs" && pwd)"

echo "ELK Stack Deployment Script"
echo "Fuente: $CONFIG_DIR"
echo "Destino: $ELK_HOME"
echo ""

# Verificar que existe la carpeta de origen
if [ ! -d "$CONFIG_DIR" ]; then
    echo "ERROR: Carpeta de configuracion no encontrada en $CONFIG_DIR"
    exit 1
fi

# Verificar que existen las instalaciones
if [ ! -d "$ELK_HOME/elasticsearch-9.2.1" ]; then
    echo "ERROR: Elasticsearch no encontrado en $ELK_HOME/elasticsearch-9.2.1"
    exit 1
fi

echo "1. Copiando configuracion Elasticsearch..."
if [ -d "$CONFIG_DIR/elasticsearch" ]; then
    cp -rv "$CONFIG_DIR/elasticsearch/"* "$ELK_HOME/elasticsearch-9.2.1/config/" || true
    echo "OK - Elasticsearch configurado"
else
    echo "AVISO: Carpeta elasticsearch no encontrada"
fi

echo ""
echo "2. Copiando configuracion Logstash..."
if [ -d "$CONFIG_DIR/logstash" ] && [ -d "$ELK_HOME/logstash-9.2.1" ]; then
    cp -rv "$CONFIG_DIR/logstash/"* "$ELK_HOME/logstash-9.2.1/config/" || true
    echo "OK - Logstash configurado"
else
    echo "AVISO: Logstash no encontrado o carpeta config no existe"
fi

echo ""
echo "3. Copiando configuracion Metricbeat..."
if [ -d "$ELK_HOME/metricbeat-9.2.1" ]; then
    cp -v "$CONFIG_DIR/metricbeat.yml" "$ELK_HOME/metricbeat-9.2.1/" || true
    echo "OK - Metricbeat configurado"
else
    echo "AVISO: Metricbeat no encontrado"
fi

echo ""
echo "4. Corrigiendo permisos..."
# Elasticsearch
chown -R g2:g2 "$ELK_HOME/elasticsearch-9.2.1/config/" 2>/dev/null || sudo chown -R g2:g2 "$ELK_HOME/elasticsearch-9.2.1/config/" || true
echo "OK - Permisos Elasticsearch"

# Metricbeat - CRITICO: los archivos .yml no deben ser escribibles por grupo/otros
if [ -d "$ELK_HOME/metricbeat-9.2.1" ]; then
    find "$ELK_HOME/metricbeat-9.2.1" -name "*.yml" -exec chmod go-w {} \; 2>/dev/null || true
    echo "OK - Permisos Metricbeat"
fi

echo ""
echo "5. Configurando systemd..."
if [ -d "$CONFIG_DIR/systemd" ]; then
    sudo cp "$CONFIG_DIR/systemd/"*.service /etc/systemd/system/
    sudo systemctl daemon-reload
    echo "OK - Systemd configurado"
    echo ""
    echo "Servicios habilitados:"
    sudo systemctl enable elasticsearch logstash metricbeat
else
    echo "AVISO: Carpeta systemd no encontrada"
fi

echo ""
echo "Deployment completado."
echo ""
echo "Proximos pasos:"
echo "  systemctl status elasticsearch"
echo "  sudo systemctl start elasticsearch logstash metricbeat"
echo "  sudo journalctl -u elasticsearch -f"
echo ""
