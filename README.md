## Fabric's user understanding challenge

Congratulations on being selected for this take home interview! The goal of this challenge is to see how you approach problem solving, especially when the “best practice” approach isn’t clear. We don’t want to constrain your thinking, so feel free to solve this challenge with any tools you deem appropriate.

### Few guidelines

1. Don’t spend more than a couple hours on this, we really just want to see how you **approach problem solving**. Not all experiment's work out, so if the output of your work isn’t great, you can find comfort in the fact we just want to **see the process**! Don’t start again from scratch, you’ll be wasting your time.
2. We value **clean code** and **clear explanations** as much as the actual solution to the challenge. Include the cell outputs of the Jupyter notebook in the final commit. We will not execute your solution so make sure the notebook clearly shows the **output of your work**.
3. We value **creativity**. If undecided between two approaches, go with the most surprising one.
4. Provide **any additional context** you think we may need to understand your approach on the notebook itself.

Apart from that, go for it! We're excited to see what you build.

### Neo4j Docker Setup

A comprehensive knowledge graph has been built using Neo4j and local embeddings. To manage the Neo4j Docker container, use the provided script:

#### Quick Start

```bash
# Make the script executable (first time only)
chmod +x ../run_neo4j.sh

# Start Neo4j container
../run_neo4j.sh start

# Check container status
../run_neo4j.sh status

# View logs
../run_neo4j.sh logs

# Stop the container
../run_neo4j.sh stop
```

#### Script Commands

- **`start`** - Start or create Neo4j container with optimized settings (default)
- **`stop`** - Stop the running container
- **`restart`** - Restart the container  
- **`status`** - Show container status
- **`logs`** - View container logs in follow mode
- **`remove`** - Remove the container and all data

#### Configuration

- **Ports**: Bolt (7687), HTTP (7474)
- **Credentials**: neo4j / password
- **Memory**: 2GB heap + 1GB page cache
- **Access**: http://localhost:7474

#### Knowledge Graph

The `2. knowledge_graph_neo4j.ipynb` notebook contains:
- Data loading from two JSON sources
- Local embeddings using `sentence-transformers` (all-MiniLM-L6-v2, 384-dimensional)
- Unified Neo4j schema with Categories, Topics, Entities, Websites, and User nodes
- Semantic search capabilities using embeddings
- Network visualization and analysis tools

See `../docs/KNOWLEDGE_GRAPH_QUERY_GUIDE.md` for complete query documentation and 40+ example queries.

## Project Files and Notebooks

### Main Notebooks

1. **`challenge.ipynb`** - The original challenge notebook with dummy approach
2. **`0. data_exploration.ipynb`** - Initial data exploration and structure analysis
3. **`1. search_extraction_analysis.ipynb`** - Search history analysis with OpenAI NER extraction (12 sections, 44 cells)
4. **`2. knowledge_graph_neo4j.ipynb`** - Complete knowledge graph construction (40 cells, fully executed)
5. **`3. gemini_script_generator.ipynb`** - Gemini-based script generation utilities

### Data Files

- **`structured_user_interests_v1.json`** - User interests with 10 categories, 36,093 topics, 3,920 entities
- **`openai_extraction_cache_latest.json`** - Cached OpenAI extractions for 19,791+ websites
- **`search_history.json`** - Google search history data (requires processing)
- **`fashion_catalog.json`** - Fashion catalog reference data

### Documentation Files

Located in `../docs/` folder:

- **`KNOWLEDGE_GRAPH_QUERY_GUIDE.md`** - Complete query documentation with 40+ Cypher examples
- **`NER_EXTRACTION_SUMMARY.md`** - Summary of NER extraction approach
- **`NER_IMPLEMENTATION_GUIDE.md`** - Detailed NER implementation guide
- **`NER_QUICK_REFERENCE.md`** - Quick reference for NER patterns
- **`OPENAI_NER_GUIDE.md`** - OpenAI NER integration guide
- **`SEARCH_EXTRACTION_SUMMARY.md`** - Search extraction methodology

### Key Statistics

**Knowledge Graph**:
- **Total Nodes**: 105,235
- **Node Types**: Category (24), Topic (52,806), Entity (45,832), Website (6,572), User (1)
- **Total Relationships**: 470,578+
- **Relationship Types**: BELONGS_TO, MENTIONS, INTERESTED_IN, VISITED, HAS_CATEGORY, HAS_TOPIC
- **Embeddings**: 384-dimensional vectors for 98,662 nodes

**Data Sources**:
- User Interests: 10 categories, 36,093 topics, 3,920 entities, 53,031 activities, 30,535 searches
- Website Extractions: 19,791 websites with extracted categories, topics, and items

### Getting started

To get started, please clone this repo and check out the `challenge.ipynb` file. The file includes the challenge and a high level description of what we consider a **dummy** approach. Make sure your solution is **significantly** better that the dummy one.

### Solution Approach

This solution implements a **unified knowledge graph** that:
1. **Extracts structured information** using Named Entity Recognition (NER) with OpenAI GPT-4o-mini
   - Analyzes search queries and visited web pages
   - Extracts semantic categories, topics, and entities
   - Implements web scraping with fallback strategies
   - Caches API responses for efficiency (saves 60-70% of calls)
2. **Combines multiple data sources** (user interests + website extractions) into a single semantic layer
3. **Uses local embeddings** (all-MiniLM-L6-v2) for efficient semantic search without external API calls
4. **Builds a comprehensive graph** with 105K+ nodes and 470K+ relationships in Neo4j
5. **Enables semantic queries** for finding related topics, entities, and websites
6. **Provides visualization tools** for network analysis and exploration

#### Key Features

**Search History Analysis** (`1. search_extraction_analysis.ipynb`):
- Processes Google search history with 12 comprehensive sections
- Performs advanced NER extraction using OpenAI GPT-4o-mini
- Extracts semantic categories, topics, and named entities
- Implements web scraping with intelligent fallback mechanisms
- Analyzes temporal patterns and search clusters
- Generates structured JSON output for downstream integration
- Tracks API usage and costs with detailed statistics

**Knowledge Graph** (`2. knowledge_graph_neo4j.ipynb`):
- Unifies data from multiple sources into single graph database
- Generates 384-dimensional embeddings for semantic search
- Creates 5 node types and 6 relationship types
- Supports complex Cypher queries for deep analysis
- Includes visualization and network analysis tools

### Running the Solution

#### Prerequisites

```bash
# Install Python dependencies
pip install -r requirements.txt

# Set up OpenAI API key (for search extraction analysis)
echo "OPENAI_API_KEY=your_key_here" > .env
```

#### Workflow

1. **Explore the data** (Optional):
   - Open `0. data_exploration.ipynb`
   - Review initial data structure and statistics

2. **Extract search history insights**:
   - Open `1. search_extraction_analysis.ipynb`
   - This performs OpenAI NER extraction on search queries and page visits
   - Generates `openai_extraction_cache_latest.json` (cached API responses)
   - Outputs structured insights to `structured_user_interests_v1.json`

3. **Build the knowledge graph**:
   - Start Neo4j: `../run_neo4j.sh start`
   - Open `2. knowledge_graph_neo4j.ipynb`
   - Execute all cells (40 cells, ~1.5 hours for full execution with embeddings)
   - Results include 105K+ nodes and 470K+ relationships

4. **Query the graph**:
   - See `../docs/KNOWLEDGE_GRAPH_QUERY_GUIDE.md` for 40+ example queries
   - Use Python functions: `search_by_similarity()`, `search_topics_detailed()`, `get_entity_connections()`
   - Access Neo4j Browser at http://localhost:7474

### Submit your solution

When you're happy with your solution, send us a link to your repo. If you don't feel like making your repo public, make a private one and invite us:

- @jskerman
- @massimoalbarello
