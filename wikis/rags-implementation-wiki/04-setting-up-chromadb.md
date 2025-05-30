# 04 - Setting up ChromaDB

## What is ChromaDB?

ChromaDB is an open-source vector database designed for AI applications. In our RAGS system, it:

- **Stores vector embeddings** of your code chunks
- **Provides fast similarity search** across millions of vectors
- **Persists data** between sessions
- **Scales efficiently** with your codebase size
- **Integrates seamlessly** with VectorCode

## Installation Options

### Option 1: Docker (Recommended)

Docker provides the easiest setup with consistent performance across platforms.

```bash
# Pull ChromaDB Docker image
docker pull chromadb/chroma:latest

# Create persistent data directory
mkdir -p ~/.local/share/chromadb

# Run ChromaDB container
docker run -d \
  --name chromadb \
  -p 8000:8000 \
  -v ~/.local/share/chromadb:/chroma/chroma \
  -e CHROMA_SERVER_HOST=0.0.0.0 \
  -e CHROMA_SERVER_HTTP_PORT=8000 \
  chromadb/chroma:latest

# Verify container is running
docker ps | grep chromadb
```

### Option 2: Python Package

For development or when Docker isn't available:

```bash
# Install ChromaDB Python package
pip3 install chromadb

# Create startup script
cat > start_chromadb.py << 'EOF'
#!/usr/bin/env python3
import chromadb
from chromadb.config import Settings

# Start ChromaDB server
client = chromadb.HttpClient(
    host="localhost",
    port=8000,
    settings=Settings(
        chroma_server_host="0.0.0.0",
        chroma_server_http_port=8000,
        persist_directory="~/.local/share/chromadb"
    )
)

print("ChromaDB server starting on http://localhost:8000")
print("Press Ctrl+C to stop")

try:
    # Keep server running
    import time
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nShutting down ChromaDB server")
EOF

chmod +x start_chromadb.py
```

### Option 3: System Service

For production-like setup:

```bash
# Create systemd service (Linux)
sudo tee /etc/systemd/system/chromadb.service > /dev/null << 'EOF'
[Unit]
Description=ChromaDB Vector Database
After=network.target

[Service]
Type=simple
User=chromadb
Group=chromadb
WorkingDirectory=/opt/chromadb
ExecStart=/usr/local/bin/docker run --rm \
  --name chromadb \
  -p 8000:8000 \
  -v /var/lib/chromadb:/chroma/chroma \
  chromadb/chroma:latest
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create chromadb user and directories
sudo useradd -r -s /bin/false chromadb
sudo mkdir -p /var/lib/chromadb
sudo chown chromadb:chromadb /var/lib/chromadb

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable chromadb
sudo systemctl start chromadb
```

## Configuration

### Basic Configuration

Update your VectorCode configuration to use ChromaDB:

```bash
# Update VectorCode config
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "vector_store": "chromadb",
  "chromadb_config": {
    "host": "localhost",
    "port": 8000,
    "persist_directory": "~/.local/share/chromadb"
  },
  "chunk_size": 512,
  "chunk_overlap": 50,
  "supported_extensions": [
    ".py", ".js", ".ts", ".lua", ".go", ".rs", 
    ".java", ".cpp", ".c", ".h", ".hpp", ".cc",
    ".md", ".txt", ".json", ".yaml", ".yml",
    ".sh", ".bash", ".zsh", ".fish"
  ]
}
EOF
```

### Advanced Configuration

For better performance and customization:

```bash
# Create advanced ChromaDB configuration
cat > ~/.config/vectorcode/chromadb.yaml << 'EOF'
# ChromaDB Configuration
server:
  host: "0.0.0.0"
  port: 8000
  cors_allow_origins: ["*"]

storage:
  persist_directory: "~/.local/share/chromadb"
  max_batch_size: 1000
  
performance:
  # Optimize for your hardware
  max_workers: 4
  batch_size: 100
  cache_size: 1000

collections:
  default_metadata:
    hnsw_space: "cosine"
    hnsw_construction_ef: 200
    hnsw_search_ef: 100
    hnsw_M: 16

logging:
  level: "INFO"
  file: "~/.local/share/chromadb/chroma.log"
EOF
```

## Testing ChromaDB

### Basic Connectivity Test

```bash
# Test ChromaDB API
curl -X GET http://localhost:8000/api/v1/heartbeat

# Check version
curl -X GET http://localhost:8000/api/v1/version

# List collections
curl -X GET http://localhost:8000/api/v1/collections
```

**Expected Output:**
```json
{"nanosecond heartbeat": 1234567890}
{"version": "0.4.0"}
{"collections": []}
```

### Python Test Script

```bash
# Create comprehensive test script
cat > test_chromadb.py << 'EOF'
#!/usr/bin/env python3
import chromadb
import requests
import time
import json

def test_chromadb_connection():
    """Test ChromaDB connection and basic operations."""
    
    print("🔍 Testing ChromaDB Connection...")
    
    try:
        # Test HTTP endpoint
        response = requests.get("http://localhost:8000/api/v1/heartbeat", timeout=5)
        if response.status_code == 200:
            print("✅ ChromaDB HTTP endpoint responding")
        else:
            print(f"❌ HTTP endpoint error: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection failed: {e}")
        print("Make sure ChromaDB is running: docker ps | grep chromadb")
        return False
    
    try:
        # Test Python client
        client = chromadb.HttpClient(host="localhost", port=8000)
        
        # Test collection operations
        collection_name = "test_collection"
        
        # Create test collection
        collection = client.create_collection(
            name=collection_name,
            metadata={"description": "Test collection for RAGS setup"}
        )
        print(f"✅ Created test collection: {collection_name}")
        
        # Add test documents
        test_docs = [
            "This is a test document about Python programming",
            "JavaScript functions and async programming",
            "Machine learning with neural networks"
        ]
        
        collection.add(
            documents=test_docs,
            ids=["doc1", "doc2", "doc3"],
            metadatas=[
                {"type": "python", "topic": "programming"},
                {"type": "javascript", "topic": "programming"}, 
                {"type": "python", "topic": "ml"}
            ]
        )
        print("✅ Added test documents")
        
        # Test query
        results = collection.query(
            query_texts=["programming languages"],
            n_results=2
        )
        print(f"✅ Query successful, found {len(results['documents'][0])} results")
        
        # Test metadata filtering
        filtered_results = collection.query(
            query_texts=["programming"],
            where={"type": "python"},
            n_results=2
        )
        print(f"✅ Metadata filtering works, found {len(filtered_results['documents'][0])} Python docs")
        
        # Clean up
        client.delete_collection(collection_name)
        print("✅ Cleaned up test collection")
        
        # Performance test
        start_time = time.time()
        large_collection = client.create_collection("performance_test")
        
        # Add many documents
        docs = [f"Document {i} with some content about topic {i%10}" for i in range(100)]
        ids = [f"doc_{i}" for i in range(100)]
        
        large_collection.add(documents=docs, ids=ids)
        
        # Query performance
        query_start = time.time()
        results = large_collection.query(query_texts=["topic"], n_results=10)
        query_time = time.time() - query_start
        
        total_time = time.time() - start_time
        
        print(f"⚡ Performance test:")
        print(f"   - Added 100 documents in {total_time:.2f}s")
        print(f"   - Query took {query_time:.3f}s")
        
        # Clean up
        client.delete_collection("performance_test")
        
        print("✅ All ChromaDB tests passed!")
        return True
        
    except Exception as e:
        print(f"❌ ChromaDB test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_chromadb_connection()
    exit(0 if success else 1)
EOF

chmod +x test_chromadb.py
python3 test_chromadb.py
```

## Integration with VectorCode

### Update VectorCode to Use ChromaDB

```bash
# Test VectorCode with ChromaDB
cd ~/test-vectorcode

# Re-index with ChromaDB backend
vectorcode vectorise --project_root . --recursive --force

# Verify collections in ChromaDB
curl -X GET http://localhost:8000/api/v1/collections | jq '.'

# Test queries
vectorcode query "fibonacci function" --verbose
```

### Verify Integration

```bash
# Create integration test script
cat > test_vectorcode_chromadb.py << 'EOF'
#!/usr/bin/env python3
import chromadb
import subprocess
import json

def test_integration():
    """Test VectorCode + ChromaDB integration."""
    
    print("🔍 Testing VectorCode + ChromaDB Integration...")
    
    # Connect to ChromaDB
    client = chromadb.HttpClient(host="localhost", port=8000)
    
    # List collections
    collections = client.list_collections()
    print(f"📋 Found {len(collections)} collections in ChromaDB")
    
    for collection in collections:
        print(f"   - {collection.name}: {collection.count()} documents")
    
    # Test VectorCode query
    try:
        result = subprocess.run(
            ["vectorcode", "query", "fibonacci", "--output", "json"],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            query_results = json.loads(result.stdout)
            print(f"✅ VectorCode query successful: {len(query_results)} results")
        else:
            print(f"❌ VectorCode query failed: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ VectorCode query timed out")
        return False
    except json.JSONDecodeError:
        print("❌ Invalid JSON response from VectorCode")
        return False
    
    print("✅ VectorCode + ChromaDB integration working!")
    return True

if __name__ == "__main__":
    success = test_integration()
    exit(0 if success else 1)
EOF

chmod +x test_vectorcode_chromadb.py
python3 test_vectorcode_chromadb.py
```

## Performance Optimization

### Memory and Storage

```bash
# Monitor ChromaDB resource usage
docker stats chromadb

# Check storage usage
du -sh ~/.local/share/chromadb

# Optimize collection settings
cat > optimize_collections.py << 'EOF'
#!/usr/bin/env python3
import chromadb

client = chromadb.HttpClient(host="localhost", port=8000)

# Get all collections
collections = client.list_collections()

for collection in collections:
    # Optimize HNSW parameters for better performance
    collection.modify(
        metadata={
            "hnsw_space": "cosine",
            "hnsw_construction_ef": 200,
            "hnsw_search_ef": 100,
            "hnsw_M": 16
        }
    )
    print(f"✅ Optimized collection: {collection.name}")

print("🚀 All collections optimized!")
EOF

python3 optimize_collections.py
```

### Backup and Maintenance

```bash
# Create backup script
cat > backup_chromadb.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="$HOME/chromadb_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/chromadb_backup_$TIMESTAMP"

echo "📦 Creating ChromaDB backup..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop ChromaDB temporarily for consistent backup
docker stop chromadb

# Create backup
cp -r ~/.local/share/chromadb "$BACKUP_PATH"

# Restart ChromaDB
docker start chromadb

# Compress backup
tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "chromadb_backup_$TIMESTAMP"
rm -rf "$BACKUP_PATH"

echo "✅ Backup created: $BACKUP_PATH.tar.gz"

# Keep only last 5 backups
ls -t "$BACKUP_DIR"/chromadb_backup_*.tar.gz | tail -n +6 | xargs -r rm

echo "🧹 Old backups cleaned up"
EOF

chmod +x backup_chromadb.sh
```

## Monitoring and Health Checks

### Health Check Script

```bash
cat > check_chromadb_health.sh << 'EOF'
#!/bin/bash

echo "🔍 Checking ChromaDB Health..."

# Check if container is running
if docker ps | grep -q chromadb; then
    echo "✅ ChromaDB container is running"
else
    echo "❌ ChromaDB container not found"
    echo "Start with: docker start chromadb"
    exit 1
fi

# Check HTTP endpoint
if curl -s http://localhost:8000/api/v1/heartbeat > /dev/null; then
    echo "✅ ChromaDB HTTP endpoint responding"
else
    echo "❌ ChromaDB HTTP endpoint not responding"
    exit 1
fi

# Check disk usage
USAGE=$(du -sh ~/.local/share/chromadb | cut -f1)
echo "💾 ChromaDB storage usage: $USAGE"

# Check collections
COLLECTIONS=$(curl -s http://localhost:8000/api/v1/collections | jq '. | length')
echo "📋 Number of collections: $COLLECTIONS"

# Check memory usage
MEMORY=$(docker stats chromadb --no-stream --format "table {{.MemUsage}}" | tail -1)
echo "🧠 Memory usage: $MEMORY"

echo "✅ ChromaDB health check complete!"
EOF

chmod +x check_chromadb_health.sh
./check_chromadb_health.sh
```

## Troubleshooting

### Common Issues

**Issue**: "Connection refused" to ChromaDB
```bash
# Check if container is running
docker ps | grep chromadb

# Start ChromaDB if stopped
docker start chromadb

# Check logs
docker logs chromadb
```

**Issue**: "Out of memory" errors
```bash
# Increase Docker memory limit
docker update --memory=4g chromadb

# Or restart with more memory
docker stop chromadb
docker run -d --name chromadb -p 8000:8000 --memory=4g \
  -v ~/.local/share/chromadb:/chroma/chroma \
  chromadb/chroma:latest
```

**Issue**: Slow query performance
```bash
# Optimize HNSW parameters
python3 optimize_collections.py

# Check collection sizes
curl -s http://localhost:8000/api/v1/collections | jq '.[] | {name: .name, count: .count}'
```

## What's Next?

Now that ChromaDB is running and integrated with VectorCode, we'll set up CodeCompanion to provide the Neovim chat interface that brings everything together.

In the next guide, we'll:
1. Install and configure CodeCompanion plugin
2. Set up Ollama adapter for local LLM integration
3. Configure VectorCode slash commands
4. Test the complete RAGS workflow in Neovim

---

**Continue to:** [05 - CodeCompanion Integration](05-codecompanion-integration.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for ChromaDB-specific issues.
