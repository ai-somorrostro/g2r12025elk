# Guía de Recuperación de Credenciales

## Problema Identificado

Los archivos `users` y `users_roles` están vacíos. Esto es **normal en Elasticsearch 9.2.1** porque las credenciales se almacenan cifradas en el keystore.

## Solución

### Opción 1: Exportar credenciales (RECOMENDADO)
```bash
# Ver usuarios existentes
/home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch-users list

# Ver roles
/home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch-users list-roles

# Backup del keystore (contiene todas las credenciales cifradas)
cp /home/g2/ELK/elasticsearch-9.2.1/config/elasticsearch.keystore \
   /home/g2/ELK/nodo-2/elk-configs/elasticsearch/
```

### Opción 2: Acceso a elasticsearch-users
Si necesitas resetear contraseñas en el nuevo nodo:
```bash
# En la nueva máquina, después de copiar la config
/home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch-reset-password \
  -u elastic \
  -i

# O generar token de enrollment
/home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch-create-enrollment-token \
  -s kibana
```

## Archivos Críticos para Recuperación

```
✅ Presente en elk-configs:
- elasticsearch.keystore    (credenciales cifradas)
- certs/http.p12          (certificado HTTPS)
- certs/transport.p12     (certificado cluster)
- elasticsearch.yml       (configuración principal)

❌ Vacíos (pero necesarios copiar):
- elasticsearch/users     (generado por elastic)
- elasticsearch/users_roles (generado por elastic)
```

## Checklist Antes de Importar en Nueva Máquina

- [ ] ¿Está `elasticsearch.keystore` en `elk-configs/elasticsearch/`?
- [ ] ¿Están presentes los certificados en `certs/`?
- [ ] ¿Está completo `elasticsearch/elasticsearch.yml`?
- [ ] ¿Está presente `logstash/` con pipelines?
- [ ] ¿Está `metricbeat.yml` presente?

## Próximos Pasos

1. **Antes de hacer git push:**
   ```bash
   cd /home/g2/ELK/nodo-2
   git status
   ```
   Verificar que `.gitignore` protege los archivos sensibles

2. **En la nueva máquina:**
   ```bash
   bash deploy.sh
   ```

3. **Resetear credenciales si es necesario:**
   ```bash
   /home/g2/ELK/elasticsearch-9.2.1/bin/elasticsearch-reset-password -u elastic -i
   ```

## Nota de Seguridad

⚠️ El `elasticsearch.keystore` contiene credenciales cifradas. Aunque está encriptado:
- NO subir a repos públicos
- Usar `.gitignore` para protegerlo
- Considerar usar variables de entorno en producción

