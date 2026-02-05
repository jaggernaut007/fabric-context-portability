# Fabric User Understanding Knowledge Graph - Documentation

This folder contains comprehensive documentation for the knowledge graph project, covering data extraction, semantic analysis, and graph querying.

## Documentation Files

### 1. **SEARCH_EXTRACTION_SUMMARY.md** ⭐ START HERE
**Overview of the search history analysis pipeline (v3)**

- Data loading, dedup, clustering, and GPT-5-nano NER extraction
- 12-section notebook structure with cost notes (sub-$1 via cluster-level calls)
- 11 semantic categories and example outputs
- Primary artifacts: `cluster_summaries.json` (+ optional `openai_extraction_cache_latest.json`)

**Best for**: Understanding how `1. search_extraction_analysis_v3.ipynb` turns raw history into structured clusters.

---

### 2. **KNOWLEDGE_GRAPH_QUERY_GUIDE.md**
**Complete reference for querying the Neo4j knowledge graph**

- Graph statistics and node types
- Property definitions for all node types
- Relationship types and their meanings
- 40+ example Cypher queries covering:
  - Basic pattern matching
  - Semantic similarity searches
  - Complex subgraph queries
  - Temporal analysis
  - Entity relationship exploration
- Query best practices
- Performance optimization tips

**Best for**: Querying and analyzing the constructed knowledge graph.

**When to use this**:
- Writing Cypher queries
- Finding related topics and entities
- Semantic search operations
- Complex graph analysis
- Understanding graph structure

---

### 3. **GEMINI_SCRIPT_GENERATOR.md**
**How to generate personalized scripts with Gemini + Neo4j context**

- Setup for Gemini and Neo4j connections
- Vector search over Categories/Topics/Entities
- Prompting for 8-second scripts
- Optional Veo video rendering to `videos/`

**Best for**: Using the `3. gemini_script_generator-v2.ipynb` notebook to create personalized scripts (and optionally videos) with knowledge-graph context.

---

### 4. **DATA_EXPLORATION.md**
**Guide to the exploratory analysis notebook**

- EDA on `search_history.json` (activity mix, temporal patterns)
- TF-IDF + K-Means/Hierarchical clustering (no APIs required)
- Data quality checks and keyword extraction

**Best for**: First-pass understanding of the dataset before running `1. search_extraction_analysis_v3.ipynb`.

---

## Project Architecture

### Data Pipeline

```
Google Search History (JSON)
        ↓
    Parse, classify, deduplicate
        ↓
    Temporal + keyword clustering
        ↓
    Cluster-level NER with GPT-5-nano
        ↓
    `cluster_summaries.json` (categories, topics, entities)
        ↓
    Neo4j knowledge graph (Category, Topic, Entity, User)
```

### Key Notebooks

1. **1. search_extraction_analysis_v3.ipynb**
   - Primary analysis notebook
   - 12 sections, 44 cells
   - Performs clustering + GPT-5-nano NER extraction
   - Outputs: `cluster_summaries.json` (+ optional `openai_extraction_cache_latest.json`)

2. **2. knowledge_graph_neo4j_V3_.ipynb**
   - Knowledge graph construction
   - 40 cells, ~1.5 hours execution
   - Ingests `cluster_summaries.json` into Neo4j with vector indexes

3. **0. data_exploration.ipynb**
   - Initial data exploration
   - Reference/reference notebook
   - No critical dependencies

4. **3. gemini_script_generator-v2.ipynb**
    - Gemini-powered script generation with Neo4j context
    - Uses vector search over the knowledge graph to personalize prompts
    - Requires `GOOGLE_API_KEY`/`GEMINI_API_KEY` and a running Neo4j instance
    - Optional Veo video generation saved to `videos/`

---

## Quick Start Guide

### For Search Analysis
1. Read: **SEARCH_EXTRACTION_SUMMARY.md**
2. Set up: OpenAI API key in `.env` (GPT-5-nano via Responses API)
3. Run: `1. search_extraction_analysis_v3.ipynb`
4. Outputs: `cluster_summaries.json` (primary), optional cache

### For Data Exploration
1. Run: `0. data_exploration.ipynb` (no API keys or Neo4j needed)
2. If NLTK data is missing: `python download_nltk_data.py`

### For Knowledge Graph
1. Read: **KNOWLEDGE_GRAPH_QUERY_GUIDE.md**
2. Start Neo4j: `../run_neo4j.sh start`
3. Run: `2. knowledge_graph_neo4j_V3_.ipynb`
4. Query: Use examples from guide

### For Gemini Script Generation
1. Start Neo4j: `../run_neo4j.sh start`
2. Set `GOOGLE_API_KEY` or `GEMINI_API_KEY` in `.env`
3. Run: `3. gemini_script_generator-v2.ipynb` to generate an 8s script (optionally call Veo to render video to `videos/`)

### For Complete Understanding
1. Start: **SEARCH_EXTRACTION_SUMMARY.md**
2. Querying: **KNOWLEDGE_GRAPH_QUERY_GUIDE.md**
3. Script generation: **GEMINI_SCRIPT_GENERATOR.md**

---

## Key Statistics

### Data Sources
- **Google Search Activity**: 53,031 records (June 8, 2017 – June 23, 2024)
- **Breakdown**: ~30,535 searches (57.6%), ~22,496 page visits (42.4%)

### Processing
- **Clustering**: Temporal + keyword clustering prior to NER
- **Extraction**: GPT-5-nano NER at cluster level (11 categories)
- **Cost**: Sub-$1 for provided dataset via dedup + cluster calls
- **Outputs**: `cluster_summaries.json` (+ optional `openai_extraction_cache_latest.json`)

### Knowledge Graph
- **Node Types**: Category, Topic, Entity, User
- **Relationships**: BELONGS_TO, MENTIONS, INTERESTED_IN, IN_CATEGORY
- **Embeddings**: all-MiniLM-L6-v2 (384-d) with vector indexes per label

---

## Feature Highlights

### ✨ Semantic Analysis
- GPT-5-nano powered cluster-level NER
- 11 semantic categories
- Context-aware entity and topic extraction
- Structured JSON outputs for downstream graph loading

### 🚀 Performance
- Cost kept low via dedup + cluster-level calls (cache optional)
- Minimal retries; no heavy scraping required
- Vectorized embeddings cached alongside graph load
- Notebook-order guidance to avoid rework

### 🔍 Advanced Querying
- 40+ example Cypher queries in the guide
- Vector search across categories/topics/entities
- Traversal patterns for entity/topic expansion
- Aggregation and statistics queries

### 📊 Knowledge Graph
- Category/Topic/Entity/User nodes with vector indexes
- Embeddings: all-MiniLM-L6-v2 (384-d)
- Neo4j integration via `knowledge_graph_neo4j_V3_.ipynb`
- Ready for downstream retrieval-augmented tasks

---

## Common Tasks

### Extract Information from Searches
→ See **SEARCH_EXTRACTION_SUMMARY.md** Section "Notebook Structure"

### Set Up OpenAI API
→ See **SEARCH_EXTRACTION_SUMMARY.md** prerequisites section

### Query Related Topics
→ See **KNOWLEDGE_GRAPH_QUERY_GUIDE.md** Section "Example Query: Find Related Topics"

### Find Top Entities in Category
→ See **SEARCH_EXTRACTION_SUMMARY.md** extraction examples

### Analyze Search Clusters
→ See **SEARCH_EXTRACTION_SUMMARY.md** Section "Section 9: Search Cluster Analysis"

### Semantic Search
→ See **KNOWLEDGE_GRAPH_QUERY_GUIDE.md** Section "Semantic Search Examples"

---

## Environment Setup

### Requirements
- Python 3.10+
- OpenAI API key (for search extraction)
- Neo4j Docker container (for knowledge graph)
- 2GB+ RAM recommended

### Installation
```bash
pip install -r requirements.txt
echo "OPENAI_API_KEY=sk-..." > .env
echo "GEMINI_API_KEY=A..." >> .env
../run_neo4j.sh start
```

---

## Documentation History

| Date | Changes |
|------|---------|
| Dec 2025 | Refreshed for GPT-5-nano cluster-level pipeline and current docs |

---

## Support & Questions

- For extraction issues: See **SEARCH_EXTRACTION_SUMMARY.md** "Troubleshooting"
- For query issues: See **KNOWLEDGE_GRAPH_QUERY_GUIDE.md** "Best Practices"
- For API setup: See **SEARCH_EXTRACTION_SUMMARY.md** prerequisites
- For data flow: See **SEARCH_EXTRACTION_SUMMARY.md**

---

**Last Updated**: December 2025 
**Status**: Current and maintained  
**Version**: 3.0 (OpenAI GPT-5-nano, Gemini 3 Pro,Veo 3.1)
