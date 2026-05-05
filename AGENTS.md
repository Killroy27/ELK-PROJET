# Contexte projet

Projet d'examen : Movies Data Platform avec ELK.

Objectif :
Créer une plateforme reproductible permettant :
- de lancer Elasticsearch, Kibana et Logstash avec Docker Compose ;
- d'ingérer le fichier movies_dataset.csv ;
- de créer deux index : movies_raw et movies_clean ;
- de nettoyer et typer les données avec Logstash ;
- de définir un mapping explicite pour movies_clean ;
- d'ajouter au moins un analyzer personnalisé ;
- de livrer 12 requêtes Elasticsearch commentées dont 5 bool ;
- de créer un dashboard Kibana avec 6 à 8 visualisations ;
- de créer un mini moteur de recherche connecté à Elasticsearch ;
- de documenter le projet dans docs/.

Dataset utilisé :
movies_dataset.csv avec les colonnes :
index, title, original_language, release_date, popularity, vote_average, vote_count, overview.

Contraintes importantes :
- Ne pas inventer de colonnes absentes comme genres, budget ou revenue.
- Documenter les limites du dataset.
- Garder movies_raw proche de la source.
- Nettoyer et enrichir movies_clean avec des champs qualité.
- Toutes les commandes destructives doivent être validées avant exécution.
- Ne jamais pousser directement sur main ou dev.