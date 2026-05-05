from fastapi import FastAPI, Query
from elasticsearch import Elasticsearch
from typing import Optional
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Movies Search API",
    description="Advanced search engine with autocomplete and faceting."
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ES_HOST = os.getenv("ELASTICSEARCH_HOST", "http://localhost:9200")
es = Elasticsearch(ES_HOST)
INDEX_NAME = "movies_clean"

@app.get("/health")
def health_check():
    try:
        return {"status": "ok", "elasticsearch_connected": es.ping()}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/search")
def search_movies(
    q: Optional[str] = Query(None),
    language: Optional[str] = Query(None),
    year_from: Optional[int] = Query(None),
    year_to: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    size: int = Query(10, ge=1, le=100)
):
    must_clauses = []
    filter_clauses = []

    if q:
        must_clauses.append({
            "multi_match": {
                "query": q,
                "fields": [
                    "title.autocomplete^5",
                    "title^3",
                    "overview"
                ],
                "fuzziness": "AUTO",
                "type": "best_fields"
            }
        })
    else:
        must_clauses.append({"match_all": {}})

    if language:
        filter_clauses.append({"term": {"original_language": language}})

    if year_from or year_to:
        year_range = {}
        if year_from: year_range["gte"] = year_from
        if year_to: year_range["lte"] = year_to
        filter_clauses.append({"range": {"release_year": year_range}})

    query = {"bool": {"must": must_clauses, "filter": filter_clauses}}
    
    highlight = {
        "pre_tags": ["<em class='highlight'>"],
        "post_tags": ["</em>"],
        "fields": {
            "title": {},
            "overview": {"fragment_size": 150, "number_of_fragments": 1}
        }
    }

    aggs = {
        "languages": {"terms": {"field": "original_language", "size": 10}},
        "decades": {"histogram": {"field": "release_year", "interval": 10}}
    }

    sort = [
        {"_score": {"order": "desc"}},
        {"popularity": {"order": "desc"}}
    ]

    try:
        response = es.search(
            index=INDEX_NAME,
            query=query,
            highlight=highlight,
            aggs=aggs,
            sort=sort,
            from_=(page - 1) * size,
            size=size
        )
        
        results = []
        for hit in response["hits"]["hits"]:
            src = hit["_source"]
            hl = hit.get("highlight", {})
            
            title_display = hl.get("title", [src.get("title", "")])[0]
            overview_display = hl.get("overview", [src.get("overview", "")])[0]
            if not hl.get("overview") and len(overview_display) > 150:
                overview_display = overview_display[:150] + "..."

            results.append({
                "movie_id": src.get("movie_id"),
                "score": hit["_score"],
                "title": title_display,
                "original_language": src.get("original_language"),
                "release_year": src.get("release_year"),
                "popularity": src.get("popularity"),
                "vote_average": src.get("vote_average"),
                "overview_excerpt": overview_display
            })

        return {
            "total_results": response["hits"]["total"]["value"],
            "page": page,
            "size": size,
            "facets": {
                "languages": response["aggregations"]["languages"]["buckets"],
                "decades": response["aggregations"]["decades"]["buckets"]
            },
            "results": results
        }
    except Exception as e:
        return {"error": str(e)}
