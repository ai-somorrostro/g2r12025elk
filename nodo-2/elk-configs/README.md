# Configuración ELK - Nodo 2 (nodo-2)

## Descripción General
Configuración específica del **nodo-2** en el cluster de Elasticsearch `g2-reto1`. Este nodo actúa como **master, data e ingest** node con seguridad SSL/TLS habilitada.

---

## Información del Nodo

| Parámetro | Valor |
|-----------|-------|
| **Nombre del Nodo** | `nodo-2` |
| **Cluster** | `g2-reto1` |
| **Roles** | master, data, ingest |
| **IP** | 192.199.1.59 |
| **Puerto HTTP** | 9200 |
| **Puerto Transport** | 9300 |
| **Versión** | 9.2.1 |

---

## Configuración de Seguridad

### SSL/TLS Habilitado
```
xpack.security.enabled: true
xpack.security.enrollment.enabled: true
xpack.security.authc.api_key.enabled: true
```

### Certificados
- **HTTP SSL**: `certs/http.p12`
- **Transport SSL**: `certs/transport.p12`
- **Verificación**: Certificate mode (ambos certificados requeridos)

### Autenticación
- Usuarios y roles definidos en `elasticsearch.yml`
- API Keys habilitadas para autenticación de aplicaciones

---

## Discovery y Clustering

### Seed Hosts (Nodos de descubrimiento)
```
discovery.seed_hosts:
  - 192.199.1.59:9300  (nodo-2 - este nodo)
  - 192.199.1.60:9300  (nodo-3)
```

### Binding
- `http.host: 0.0.0.0` - Escucha en todas las interfaces
- `transport.host: 0.0.0.0` - Comunicación intra-cluster en todas las interfaces

---

## Estructura de Archivos

```
nodo-2/elk-configs/
├── README.md                          # Este archivo
├── .gitignore                         # Archivos a ignorar en Git
├── metricbeat.yml                     # Configuración Metricbeat
├── certs/                             # Certificados SSL/TLS
│   ├── http.p12                       # Certificado HTTP (PKCS12)
│   ├── transport.p12                  # Certificado Transport (PKCS12)
│   └── http_ca.crt                    # CA certificate
├── elasticsearch/                     # Configuración Elasticsearch
│   ├── elasticsearch.yml              # Config principal
│   ├── jvm.options                    # Configuración JVM
│   ├── log4j2.properties              # Logging
│   ├── roles.yml                      # Definición de roles
│   ├── users                          # Base de datos usuarios
│   ├── users_roles                    # Mapeo usuario-rol
│   ├── jvm.options.d/                 # Configuración JVM adicional
│   ├── synonyms/                      # Sinónimos (es, etc.)
│   ├── certs/                         # Copia de certificados
│   └── elasticsearch-plugins.example.yml
├── logstash/                          # Configuración Logstash
│   ├── logstash.yml                   # Config principal
│   ├── pipelines.yml                  # Definición de pipelines
│   ├── config-scrapper/               # Pipeline scrapper
│   │   ├── 1-input.conf
│   │   ├── 10-filter.conf
│   │   └── 20-output.conf
│   ├── jvm.options                    # Configuración JVM
│   ├── log4j2.properties              # Logging
│   └── startup.options
└── systemd/                           # Archivos systemd
    ├── elasticsearch.service
    ├── logstash.service
    └── metricbeat.service
```

---

## Configuración de Logs

Ubicación: `/home/g2/ELK/elasticsearch-9.2.1/logs/`

**Archivos de log:**
- `g2-reto1.log` - Log general
- `g2-reto1_audit.json` - Log de auditoría (JSON)
- `g2-reto1_deprecation.json` - Avisos de deprecación
- `g2-reto1_index_*.json` - Logs de indexación

---

## Configuración de Datos

Ubicación: `/home/g2/ELK/elasticsearch-9.2.1/data/`

Contiene:
- Índices de Elasticsearch
- State del cluster
- Snapshots en caché
- Información de nodos

---

## Configuración de Systemd

**Service files**: Incluidos en esta carpeta

**Comandos útiles:**
```bash
# Ver estado
systemctl status elasticsearch

# Iniciar/Detener
sudo systemctl start elasticsearch
sudo systemctl stop elasticsearch
sudo systemctl restart elasticsearch

# Ver logs
sudo journalctl -u elasticsearch -f

# Habilitar en arranque
sudo systemctl enable elasticsearch
```

---

## Deployment en Nueva Máquina

### 1. Preparación
```bash
# Copiar configuración Elasticsearch
cp -r elasticsearch /home/g2/ELK/elasticsearch-9.2.1/config
# Esto copia: elasticsearch.yml, roles.yml, users, users_roles, jvm.options, log4j2.properties

# Copiar certificados
cp -r certs /home/g2/ELK/elasticsearch-9.2.1/config/

# Copiar Logstash
cp -r logstash /home/g2/ELK/logstash-9.2.1/

# Copiar Metricbeat
cp metricbeat.yml /home/g2/ELK/metricbeat-9.2.1/
```

### 2. Configurar Systemd
```bash
# Copiar service files
sudo cp systemd/*.service /etc/systemd/system/

# Recargar systemd
sudo systemctl daemon-reload

# Habilitar servicios
sudo systemctl enable elasticsearch logstash metricbeat
```

### 3. Corregir Permisos
```bash
# Elasticsearch
chown -R g2:g2 /home/g2/ELK/elasticsearch-9.2.1/config/

# Metricbeat (crítico)
find /home/g2/ELK/metricbeat-9.2.1 -name "*.yml" -exec chmod go-w {} \;
```

### 4. Iniciar Servicios
```bash
sudo systemctl start elasticsearch
sudo systemctl start logstash
sudo systemctl start metricbeat

# Verificar
systemctl status elasticsearch
systemctl status logstash
systemctl status metricbeat
```

---

## Configuración Logstash

Ubicación: `/home/g2/ELK/logstash-9.2.1/config/`

**Archivos:**
- `pipelines.yml` - Definición de pipelines
- `logstash.yml` - Configuración principal
- Pipelines específicos en subdirectorio

---

## Configuración Metricbeat

Ubicación: `/home/g2/ELK/metricbeat-9.2.1/`

**Archivo principal:**
- `metricbeat.yml` - Configuración de Metricbeat

**Módulos:**
- `modules.d/system.yml` - Recolección de métricas del sistema

**Notas de permisos:**
- Los archivos `.yml` deben tener permisos `chmod go-w` 
- No pueden ser escribibles por grupo/otros

---

## Notas Importantes

### ⚠️ Seguridad y Credenciales
- **Keystore cifrado** - Las credenciales se almacenan en `elasticsearch.keystore`
- Los archivos `users` y `users_roles` están vacíos (normal en ES 9.2.1)
- Ver `CREDENCIALES.md` para instrucciones de recuperación
- **No commiter keystore** sin protección - Está en `.gitignore`
- Los certificados P12 también están protegidos en `.gitignore`

### 🔐 Certificados
- Los certificados tienen fecha de expiración
- Formato: PKCS12 (.p12)
- Requieren contraseña para acceso

### 📊 Monitoreo
- Logs de auditoría en formato JSON para parsing automático
- Integración con Logstash para centralización de logs

### 🚀 Performance
- Configuración JVM por defecto: `-Xms4m -Xmx64m`
- Ajustar según disponibilidad de recursos
- Ver `jvm.options` para tuning avanzado

---

## Troubleshooting

### Elasticsearch no inicia con systemd
```bash
# Ver logs detallados
sudo journalctl -u elasticsearch -n 50

# Verificar configuración
/home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch --help
```

### Metricbeat se reinicia constantemente
```bash
# Verificar permisos de YAML
ls -la /home/g2/ELK/metricbeat-9.2.1/*.yml
ls -la /home/g2/ELK/metricbeat-9.2.1/modules.d/

# Deben ser: -rw-r--r-- (no rwxrwxr-x)
```

### Problemas de certificados
```bash
# Verificar que certificados existen
ls -la /home/g2/ELK/elasticsearch-9.2.1/config/certs/

# Verificar contenido del certificado
keytool -list -v -keystore /home/g2/ELK/elasticsearch-9.2.1/config/certs/http.p12
```

---

## Referencias

- **Elasticsearch Docs**: https://www.elastic.co/guide/en/elasticsearch/reference/current/
- **Security**: https://www.elastic.co/guide/en/elasticsearch/reference/current/security-settings.html
- **Discovery**: https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html
- **Logstash**: https://www.elastic.co/guide/en/logstash/current/
- **Metricbeat**: https://www.elastic.co/guide/en/beats/metricbeat/current/

---

## Historial de Cambios

| Fecha | Cambio | Usuario |
|-------|--------|---------|
| 2025-12-05 | Creación inicial - Migración a systemd | g2 |

