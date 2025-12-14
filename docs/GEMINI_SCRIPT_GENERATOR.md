# Gemini Script Generator (v2) Guide

This document explains how to use `3. gemini_script_generator-v2.ipynb` to create personalized 8-second scripts using Google Gemini, enriched with context from the Neo4j knowledge graph, and optionally render a short video with Veo.

## What this notebook does
- Connects to Neo4j and uses vector indexes to fetch relevant `Category`, `Topic`, and `Entity` nodes based on a user request.
- Builds a context block from the graph results and prompts Gemini (`gemini-3-pro-preview` by default) to write a personalized 8-second script.
- (Optional) Calls Veo 3 to render the script to a video saved under `videos/`.

## Prerequisites
- Neo4j container running with the Fabric knowledge graph loaded (`../run_neo4j.sh start`).
- Environment variables in `.env`:
  - `GOOGLE_API_KEY` or `GEMINI_API_KEY` (for Gemini and Veo)
  - `NEO4J_URI` (default `bolt://localhost:7687`)
  - `NEO4J_USER` (default `neo4j`)
  - `NEO4J_PASSWORD` (default `password`)
- Python dependencies from `requirements.txt` (`%pip install -q -r requirements.txt`).

## How to run (notebook steps)
1. **Install + imports**: Run the first cell to install requirements and suppress warnings.
2. **Env + clients**: Load `.env`, initialize Neo4j connection, and initialize Gemini client (warns if API key missing).
3. **Embeddings + search**: Load `all-MiniLM-L6-v2`; `search_knowledge_graph()` queries Neo4j vector indexes (`topic_embedding_idx`, `entity_embedding_idx`, `category_embedding_idx`).
4. **Generate script**: Call `generate_script_with_context(user_request)` to:
   - Embed the request
   - Pull top related topics/entities/categories
   - Build a context block
   - Ask Gemini for an 8s script (Title, Logline, Scene, Action, Audio sections)
5. **(Optional) Render video**: `create_video_from_script(script_text)` calls Veo (`veo-3.1-fast-generate-preview`), polls until done, and downloads the MP4 to `videos/generated_video_<timestamp>.mp4`.

## Tips
- Keep requests concise for better retrieval quality (the code truncates text before embedding).
- If Neo4j is not running or indexes are missing, the search step will return an empty context and the script will fall back to a generic response.
- Ensure API keys are valid; without them the notebook will skip Gemini/Veo generation.

## Outputs
- Personalized script text printed in the notebook.
- (Optional) MP4 video saved in `videos/` when Veo generation succeeds.

## Troubleshooting
- **No Gemini client**: Check `GOOGLE_API_KEY`/`GEMINI_API_KEY` in `.env`.
- **Neo4j connection failed**: Ensure container is running and credentials match.
- **Vector index errors**: Verify the graph was built with vector indexes (`topic_embedding_idx`, `entity_embedding_idx`, `category_embedding_idx`).
- **Video not downloaded**: Some Veo responses omit a direct URI; the notebook attempts a fallback download via the client.
