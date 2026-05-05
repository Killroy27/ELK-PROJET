#!/usr/bin/env bash
# ================================================================
# elasticsearch/scripts/create_indices.sh
# Création de l'index movies_clean avec son mapping explicite
# Usage: bash elasticsearch/scripts/create_indices.sh
# ================================================================

ES_URL="http://localhost:9200"
INDEX_NAME="movies_clean"
MAPPING_FILE="elasticsearch/mappings/movies_clean_mapping.json"

echo "=== Gestion de l'index : $INDEX_NAME ==="

# 1. Vérifier si l'index existe déjà, si oui le supprimer (destruction propre)
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$ES_URL/$INDEX_NAME")
if [ "$STATUS_CODE" -eq 200 ]; then
  echo "[-] L'index $INDEX_NAME existe déjà. Suppression en cours..."
  curl -s -X DELETE "$ES_URL/$INDEX_NAME" > /dev/null
  echo "[-] Index supprimé."
fi

# 2. Créer l'index avec le mapping JSON
echo "[+] Création de l'index $INDEX_NAME avec le mapping défini dans $MAPPING_FILE..."
CREATE_RESP=$(curl -s -X PUT "$ES_URL/$INDEX_NAME" -H "Content-Type: application/json" -d @"$MAPPING_FILE")

# Vérification du succès
if echo "$CREATE_RESP" | grep -q '"acknowledged":true'; then
  echo -e "\n[OK] Index $INDEX_NAME créé avec succès !"
else
  echo -e "\n[KO] Erreur lors de la création de l'index :"
  echo "$CREATE_RESP"
fi

echo "=========================================="
