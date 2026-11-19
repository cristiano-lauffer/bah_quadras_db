#!/usr/bin/env bash
# Gera bah_quadras_reset_completo.sql juntando todos os scripts na ordem de execução.
# Rode de novo sempre que alterar algum script (no Windows: pelo Git Bash).
export LC_ALL=C   # mesma ordem de arquivos em qualquer sistema/idioma
cd "$(dirname "$0")" || exit 1
OUT=bah_quadras_reset_completo.sql
{
  echo "-- GERADO por gerar_completo.sh: não edite à mão, edite os scripts e gere de novo."
  echo "-- ATENÇÃO: APAGA e recria o banco bah_quadras e o usuário usr_app_bah_quadras."
  echo "-- Uso: mysql -u root -p < $OUT"
  echo "SET NAMES utf8mb4;"
  echo "DROP DATABASE IF EXISTS bah_quadras;"
  echo "DROP USER IF EXISTS usr_app_bah_quadras;"
  echo
  for f in 01_db/*.sql 02_users/*.sql; do echo "-- >>> $f"; cat "$f"; echo; done
  echo "USE bah_quadras;"
  for d in 03_grants 04_tables 05_triggers 99_inserts; do
    for f in $(ls "$d"/*.sql | sort); do echo; echo "-- >>> $f"; cat "$f"; echo; done
  done
} > "$OUT"
echo "Gerado: $OUT"
