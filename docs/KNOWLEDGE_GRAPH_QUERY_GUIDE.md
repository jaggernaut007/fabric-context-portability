# Knowledge Graph Query Guide

## Overview

This guide describes how to query the Neo4j knowledge graph built from `cluster_summaries.json` (clustered user activity). It supersedes the earlier mixed-source graph and now focuses on Categories, Topics, Entities, and a single User profile.

> Tip: Exact counts depend on the current `cluster_summaries.json`. Run the **Graph statistics** queries below to get live numbers for your run.

### Graph Statistics (run-time)
- Total node counts by label (Category, Topic, Entity, User)
- Relationship counts by type (BELONGS_TO, MENTIONS, INTERESTED_IN, IN_CATEGORY)

---

## Node Types and Properties

### 1. Category Node
Represents semantic categories derived from cluster summaries.

**Properties**:
- `category_id` (String, Unique): Cleaned identifier from category name
- `name` (String, Unique): Full category name
- `source` (String): `cluster_summaries`
- `activity_count` (Integer): Number of activities in the cluster source
- `search_count` (Integer): Reserved; may be 0 for cluster-only runs
- `embedding` (List): 384-dimensional vector embedding

**Example Categories**:
- Technology & Innovation
- Wellness & Health
- Business & Finance
- Fashion & Accessories

---

### 2. Topic Node
Represents semantic topics parsed from clusters.

**Properties**:
- `topic_id` (String, Unique): Cluster-scoped identifier
- `content` (String): Topic text
- `source` (String): `cluster_summaries`
- `cluster_id` (String): Source cluster id
- `is_url` (Boolean): Whether the topic is a URL (false for cluster summaries)
- `embedding` (List): 384-dimensional vector embedding

**Example Topics**:
- "machine learning algorithms"
- "artificial intelligence trends"
- "luxury fashion accessories"

---

### 3. Entity Node
Represents extracted items/entities from clusters.

**Properties**:
- `entity_id` (String, Unique): Cleaned identifier
- `name` (String): Entity name
- `source` (String): `cluster_summaries`
- `entity_type` (String): Typically `item`
- `mention_count` (Integer): Number of mentions in clusters
- `category` (String): Category name from the cluster
- `embedding` (List): 384-dimensional vector embedding

**Example Entities**:
- "Apple" (company)
- "Python" (programming language)
- "Tesla" (company)

---

### 4. User Node
Single aggregated user node combining all activities.

**Properties**:
- `user_id` (String, Unique): "user_001"
- `total_activities` (Integer): Total user activities
- `total_searches` (Integer): Total searches performed
- `total_page_visits` (Integer): Total page visits
- `created_at` (DateTime): Graph creation timestamp

---

## Relationship Types

### BELONGS_TO
Topic belongs to a Category.
```
(Topic)-[:BELONGS_TO]->(Category)
```
- Properties: None

### MENTIONS
Topic mentions an Entity.
```
(Topic)-[:MENTIONS]->(Entity)
```
- Properties: None

### INTERESTED_IN
User is interested in a Topic.
```
(User)-[:INTERESTED_IN]->(Topic)
```
- Properties: None

### IN_CATEGORY
Entity is associated with a Category.
```
(Entity)-[:IN_CATEGORY]->(Category)
```
- Properties: None

---

## Query Examples

All examples below use vector indexes (`category_embedding_idx`, `topic_embedding_idx`, `entity_embedding_idx`). Replace the `embedding` parameter with your own vector (384-d from `all-MiniLM-L6-v2`).

### 1) Category vector search (Cypher)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('category_embedding_idx', 10, emb)
YIELD node, score
RETURN node.name AS category, score
ORDER BY score DESC
LIMIT 5;
```

### 2) Topic vector search (Cypher)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('topic_embedding_idx', 25, emb)
YIELD node, score
RETURN node.topic_id AS topic_id, node.content AS topic, score
ORDER BY score DESC
LIMIT 10;
```

### 3) Entity vector search (Cypher)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('entity_embedding_idx', 25, emb)
YIELD node, score
RETURN node.name AS entity, node.category AS category, score
ORDER BY score DESC
LIMIT 10;
```

### 4) Topic → entities expansion (vector + traversal)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('topic_embedding_idx', 20, emb)
YIELD node AS t, score
WITH t, score
OPTIONAL MATCH (t)-[:MENTIONS]->(e:Entity)
RETURN t.topic_id AS topic_id, t.content AS topic, score,
       COLLECT(DISTINCT e.name)[0..5] AS sample_entities
ORDER BY score DESC
LIMIT 10;
```

### 5) Entity bridge between topics (vector seed)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('entity_embedding_idx', 15, emb)
YIELD node AS e, score
MATCH (t:Topic)-[:MENTIONS]->(e)
RETURN e.name AS entity, score,
       COLLECT(DISTINCT t.content)[0..5] AS related_topics
ORDER BY score DESC
LIMIT 10;
```

### 6) Python helper (notebook)
```python
query_text = "machine learning"
similar_topics = search_by_similarity(query_text, node_type='Topic', limit=10)
similar_entities = search_by_similarity(query_text, node_type='Entity', limit=10)
similar_categories = search_by_similarity(query_text, node_type='Category', limit=5)
```

#### Get detailed topic information with similarity
```python
search_query = "python programming"
detailed_topics = search_topics_detailed(search_query, limit=5)
```

---

### 6. Network Traversal Queries

#### Find all connected nodes from a topic
```cypher
MATCH (t:Topic {topic_id: "user_an_api_13"})
OPTIONAL MATCH (t)-[:BELONGS_TO]->(c:Category)
OPTIONAL MATCH (t)-[:MENTIONS]->(e:Entity)
OPTIONAL MATCH (u:User)-[:INTERESTED_IN]->(t)
RETURN 
  t.content as topic,
  c.name as category,
  COLLECT(DISTINCT e.name)[0..5] as entities,
  COUNT(DISTINCT u) as user_interest
```

#### Find path between two entities
```cypher
MATCH path = shortestPath((e1:Entity {name: "Apple"})-[*]-(e2:Entity {name: "Google"}))
RETURN path
LIMIT 1
```

#### Get common topics between two entities
```cypher
MATCH (e1:Entity {name: "Python"})<-[:MENTIONS]-(t:Topic)-[:MENTIONS]->(e2:Entity {name: "Machine Learning"})
RETURN DISTINCT t.content
LIMIT 20
```

---

### 7. Aggregation Queries

#### Get category statistics
```cypher
MATCH (c:Category)
OPTIONAL MATCH (t:Topic)-[:BELONGS_TO]->(c)
OPTIONAL MATCH (t)-[:MENTIONS]->(e:Entity)
RETURN 
  c.name,
  COUNT(DISTINCT t) as topic_count,
  COUNT(DISTINCT e) as entity_count,
  c.source
ORDER BY topic_count DESC
```

#### Get source distribution
```cypher
MATCH (n)
UNWIND labels(n) as label
RETURN label, COUNT(*) as count
ORDER BY count DESC
```

#### Get relationship type statistics (post-vector selection)
```cypher
// Run a vector search first, then aggregate relationships on the subset
WITH $embedding AS emb
CALL db.index.vector.queryNodes('topic_embedding_idx', 200, emb)
YIELD node AS t
MATCH (t)-[r]->()
RETURN type(r) AS relationship_type, COUNT(*) AS count
ORDER BY count DESC;
```

---

## Using Python Functions

### Available Functions in the Notebook

#### 1. search_by_similarity()
Search for similar nodes by semantic embedding.

```python
# Parameters
query_text = "your search query"      # String: text to search for
node_type = 'Entity'                  # 'Entity', 'Topic', or 'Category'
limit = 5                             # Integer: max results to return

# Usage
results = search_by_similarity(query_text, node_type=node_type, limit=limit)

# Returns: List of dicts with 'node_id', 'node_type', 'similarity' (0-1 scale)
for result in results:
    print(f"{result['node_id']}: {result['similarity']:.4f}")
```

#### 2. search_topics_detailed()
Get detailed information about similar topics.

```python
# Parameters
query_text = "your search query"      # String: text to search for
limit = 5                             # Integer: max results to return

# Usage
detailed_topics = search_topics_detailed(query_text, limit=limit)

# Returns: List of dicts with detailed topic information
for topic in detailed_topics:
    print(f"Topic: {topic['topic_id']}")
    print(f"Content: {topic['content']}")
    print(f"Category: {topic['category']}")
    print(f"Entities: {topic['entities']}")
    print(f"Similarity: {topic['similarity']:.4f}")
```

#### 3. get_entity_connections()
Get all connections for a specific entity.

```python
# Usage
entity_name = "Apple"
connections = get_entity_connections(entity_name)

# Returns: Dict with entity information and related entities
print(f"Entity: {connections['entity']}")
print(f"Topic mentions: {connections['topic_mentions']}")
print(f"Related entities: {connections['related_entities']}")
```

#### 4. neo4j_conn.query()
Execute raw Cypher queries.

```python
# Usage
query = """
MATCH (c:Category)
RETURN c.name, COUNT(*) as count
ORDER BY count DESC
LIMIT 10
"""
results = neo4j_conn.query(query)

for row in results:
    print(f"{row['c.name']}: {row['count']}")
```

---

## Performance Tips (vector-first)

- Keep `k` modest when calling `db.index.vector.queryNodes` (e.g., 50–200) and post-filter with OPTIONAL MATCH.
- Always pass 384-d embeddings (`all-MiniLM-L6-v2`); truncate/clean input text before embedding.
- For analysis on subsets, run vector search first, then traverse/aggregate on the returned nodes only.

## Common Query Patterns (vector-seeded)

### Pattern 1: Vector-seeded recommendations
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('topic_embedding_idx', 50, emb)
YIELD node AS t, score
OPTIONAL MATCH (t)-[:BELONGS_TO]->(c:Category)
OPTIONAL MATCH (t)-[:MENTIONS]->(e:Entity)
RETURN t.content AS topic, c.name AS category, score,
       COLLECT(DISTINCT e.name)[0..3] AS sample_entities
ORDER BY score DESC
LIMIT 15;
```

### Pattern 2: Trending entities from vector cohort
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('entity_embedding_idx', 100, emb)
YIELD node AS e, score
MATCH (t:Topic)-[:MENTIONS]->(e)
RETURN e.name AS entity, score,
       COUNT(DISTINCT t) AS topic_mentions
ORDER BY score DESC, topic_mentions DESC
LIMIT 20;
```

### Pattern 3: Bridge topics via shared entities (vector seed)
```cypher
WITH $embedding AS emb
CALL db.index.vector.queryNodes('topic_embedding_idx', 40, emb)
YIELD node AS t1, score
MATCH (t1)-[:MENTIONS]->(e:Entity)<-[:MENTIONS]-(t2:Topic)
WHERE t1 <> t2
RETURN t1.content AS seed_topic, t2.content AS related_topic,
       e.name AS shared_entity, score
ORDER BY score DESC
LIMIT 25;
```

---

## Troubleshooting

### Query returns no results
1. Check label spelling (case-sensitive): `Category`, `Topic`, `Entity`, `User`
2. Verify property names (lowercase with underscores)
3. Check property values with DISTINCT queries first:
```cypher
MATCH (c:Category)
RETURN DISTINCT c.name
LIMIT 10
```

### Query is slow
1. Check if using indexed properties
2. Add LIMIT to test queries
3. Use PROFILE to analyze execution:
```cypher
PROFILE
MATCH (t:Topic)-[:MENTIONS]->(e:Entity)
RETURN t, e
LIMIT 100
```

### Connection errors
Ensure Neo4j is running:
```bash
docker ps | grep neo4j
docker start neo4j  # If not running
```

---

## Graph Visualization

View the graph in Neo4j Browser:
- **URL**: http://localhost:7474
- **Username**: neo4j
- **Password**: password

Quick visualization queries:
```cypher
# Show category with topics and entities
MATCH (c:Category {name: "Technology & Innovation"})
MATCH (t:Topic)-[:BELONGS_TO]->(c)
MATCH (t)-[:MENTIONS]->(e:Entity)
RETURN c, t, e
LIMIT 100
```

---

### Dataset Information

### Cluster Summaries Data Source
- **File**: `cluster_summaries.json`
- **Contents**: Clustered user activity with `category`, `topic`, and `items`
- **Derived Nodes**: Categories, Topics, Entities (items) plus a single User node

### Embeddings
- **Model**: sentence-transformers `all-MiniLM-L6-v2`
- **Dimension**: 384
- **Nodes Embedded**: All Categories, Topics, Entities created from cluster summaries

---

## Additional Resources

For more information:
- Neo4j Documentation: https://neo4j.com/docs/
- Cypher Query Language: https://neo4j.com/docs/cypher-manual/current/
- Sentence Transformers: https://www.sbert.net/

