#!/usr/bin/env bash
# ================================================================
# elasticsearch/scripts/healthcheck.sh
# Vérifie que les services ELK répondent correctement
# Usage : bash elasticsearch/scripts/healthcheck.sh
# ================================================================

set -euo pipefail

ES_URL="${ES_URL:-http://localhost:9200}"
KB_URL="${KB_URL:-http://localhost:5601}"
PASS=true

# ── Couleurs ───────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

separator() { echo -e "${CYAN}══════════════════════════════════════════════${NC}"; }

separator
echo -e "${CYAN}  Movies ELK Platform — Health Check${NC}"
separator

# ── 1. Elasticsearch cluster health ───────────────────────────
echo -e "\n${YELLOW}[1/4] Elasticsearch — cluster health${NC}"
ES_HEALTH=$(curl -s --max-time 5 "${ES_URL}/_cluster/health" 2>/dev/null || echo "")

if [ -z "$ES_HEALTH" ]; then
  echo -e "  ${RED}✗ Elasticsearch inaccessible sur ${ES_URL}${NC}"
  PASS=false
else
  STATUS=$(echo "$ES_HEALTH" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
  NODES=$(echo "$ES_HEALTH" | grep -o '"number_of_nodes":[0-9]*' | cut -d':' -f2)
  if [ "$STATUS" = "green" ] || [ "$STATUS" = "yellow" ]; then
    echo -e "  ${GREEN}✓ Elasticsearch UP — status=${STATUS}, nœuds=${NODES}${NC}"
  else
    echo -e "  ${RED}✗ Elasticsearch status inattendu : ${STATUS}${NC}"
    PASS=false
  fi
fi

# ── 2. Elasticsearch — liste des index ────────────────────────
echo -e "\n${YELLOW}[2/4] Elasticsearch — index existants${NC}"
INDICES=$(curl -s --max-time 5 "${ES_URL}/_cat/indices?h=index,docs.count,store.size&s=index" 2>/dev/null || echo "")

if [ -z "$INDICES" ]; then
  echo -e "  ${YELLOW}⚠ Aucun index ou ES inaccessible${NC}"
else
  echo "$INDICES" | while read -r line; do
    echo "  → $line"
  done
fi

# ── 3. Vérification des index movies ─────────────────────────
echo -e "\n${YELLOW}[3/4] Index movies_raw et movies_clean${NC}"
for INDEX in movies_raw movies_clean; do
  COUNT_RESP=$(curl -s --max-time 5 "${ES_URL}/${INDEX}/_count" 2>/dev/null || echo "")
  if echo "$COUNT_RESP" | grep -q '"count"'; then
    COUNT=$(echo "$COUNT_RESP" | grep -o '"count":[0-9]*' | cut -d':' -f2)
    echo -e "  ${GREEN}✓ ${INDEX} — ${COUNT} documents${NC}"
  else
    echo -e "  ${YELLOW}⚠ ${INDEX} — inexistant ou vide (normal avant ingestion)${NC}"
  fi
done

# ── 4. Kibana status ──────────────────────────────────────────
echo -e "\n${YELLOW}[4/4] Kibana — status${NC}"
KB_STATUS=$(curl -s --max-time 10 "${KB_URL}/api/status" 2>/dev/null || echo "")

if [ -z "$KB_STATUS" ]; then
  echo -e "  ${RED}✗ Kibana inaccessible sur ${KB_URL}${NC}"
  PASS=false
else
  LEVEL=$(echo "$KB_STATUS" | grep -o '"level":"[^"]*"' | head -1 | cut -d'"' -f4)
  if [ "$LEVEL" = "available" ]; then
    echo -e "  ${GREEN}✓ Kibana UP — level=${LEVEL}${NC}"
  else
    echo -e "  ${YELLOW}⚠ Kibana répond mais level=${LEVEL} (démarrage en cours ?)${NC}"
  fi
fi

# ── Résultat final ────────────────────────────────────────────
separator
if [ "$PASS" = true ]; then
  echo -e "${GREEN}  ✓ Stack ELK opérationnelle${NC}"
else
  echo -e "${RED}  ✗ Des services sont inaccessibles — vérifier avec : docker compose logs${NC}"
fi
separator
