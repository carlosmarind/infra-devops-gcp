#!/bin/bash

HOSTNAME=$1 # Reemplaza con el nombre de host que deseas resolver

echo "Esperando que $HOSTNAME se resuelva..."

while ! nslookup "$HOSTNAME" > /dev/null 2>&1; do
  echo "DNS para $HOSTNAME aún no resuelto. Reintentando en 5 segundos..."
  sleep 5
done

echo "¡$HOSTNAME resuelto! Iniciando ping..."
ping "$HOSTNAME"