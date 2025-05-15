# Building a Code Indexing System

A key component of our local AI coding assistant is a robust code indexing system. This system will parse, analyze, and index your codebase, enabling the AI to understand the context of your code and provide relevant assistance. In this guide, we'll build a complete code indexing system using Python.

## Understanding Code Indexing

Code indexing involves:

1. **Parsing**: Reading and understanding code files
2. **Chunking**: Breaking code into meaningful segments
3. **Embedding**: Converting code chunks into vector representations
4. **Indexing**: Storing these vectors for efficient retrieval

A good indexing system enables the AI to:
- Find relevant code snippets based on semantic meaning
- Understand relationships between different parts of the codebase
- Provide context-aware completions and answers

## Setting Up the Project Structure

Let's start by setting up our project structure:

```bash
mkdir -p local-ai-assistant/code-indexer
cd local-ai-assistant/code-indexer
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

Now, let's install the required packages:

```bash
pip install langchain langchain-community sentence-transformers chromadb pydantic tqdm gitpython
```

## Creating the Code Parser

First, we'll create a code parser that can handle different programming languages:

```python
# code_parser.py
import os
from typing import List, Dict, Optional
from pathlib import Path
import fnmatch

class CodeParser:
    """Parser for extracting code from repositories."""
    
    def __init__(self, repo_path: str, ignore_patterns: Optional[List[str]] = None):
        """
        Initialize the code parser.
        
        Args:
            repo_path: Path to the repository
            ignore_patterns: List of glob patterns to ignore
        """
        self.repo_path = Path(repo_path)
        self.ignore_patterns = ignore_patterns or [
            "*.git/*", "*.pyc", "__pycache__/*", "*.ipynb_checkpoints/*",
            "*.venv/*", "*venv/*", "*node_modules/*", "*.DS_Store",
            "*.idea/*", "*.vscode/*", "*.png", "*.jpg", "*.jpeg", "*.gif",
            "*.svg", "*.ico", "*.pdf", "*.zip", "*.tar.gz", "*.jar"
        ]
    
    def should_ignore(self, file_path: str) -> bool:
        """Check if a file should be ignored based on ignore patterns."""
        for pattern in self.ignore_patterns:
            if fnmatch.fnmatch(file_path, pattern):
                return True
        return False
    
    def get_file_language(self, file_path: str) -> Optional[str]:
        """Determine the programming language of a file based on its extension."""
        ext = os.path.splitext(file_path)[1].lower()
        language_map = {
            '.py': 'python',
            '.js': 'javascript',
            '.ts': 'typescript',
            '.jsx': 'javascript',
            '.tsx': 'typescript',
            '.java': 'java',
            '.c': 'c',
            '.cpp': 'cpp',
            '.h': 'c',
            '.hpp': 'cpp',
            '.cs': 'csharp',
            '.go': 'go',
            '.rb': 'ruby',
            '.php': 'php',
            '.swift': 'swift',
            '.kt': 'kotlin',
            '.rs': 'rust',
            '.lua': 'lua',
            '.sh': 'bash',
            '.html': 'html',
            '.css': 'css',
            '.scss': 'scss',
            '.sql': 'sql',
            '.md': 'markdown',
            '.json': 'json',
            '.xml': 'xml',
            '.yaml': 'yaml',
            '.yml': 'yaml',
            '.toml': 'toml',
        }
        return language_map.get(ext)
    
    def parse_file(self, file_path: str) -> Dict:
        """Parse a single file and return its content with metadata."""
        abs_path = os.path.join(self.repo_path, file_path)
        try:
            with open(abs_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            language = self.get_file_language(file_path)
            return {
                'path': file_path,
                'content': content,
                'language': language,
                'size': len(content)
            }
        except Exception as e:
            print(f"Error parsing file {file_path}: {e}")
            return None
    
    def parse_repository(self) -> List[Dict]:
        """Parse all files in the repository."""
        parsed_files = []
        
        for root, _, files in os.walk(self.repo_path):
            rel_root = os.path.relpath(root, self.repo_path)
            for file in files:
                rel_path = os.path.join(rel_root, file)
                if rel_path.startswith('./'):
                    rel_path = rel_path[2:]
                
                if self.should_ignore(rel_path):
                    continue
                
                parsed_file = self.parse_file(rel_path)
                if parsed_file:
                    parsed_files.append(parsed_file)
        
        return parsed_files
```

## Implementing Code Chunking

Next, we'll implement a chunking strategy to break code into meaningful segments:

```python
# code_chunker.py
from typing import List, Dict, Optional
import re

class CodeChunker:
    """Chunker for breaking code into meaningful segments."""
    
    def __init__(self, max_chunk_size: int = 1000, overlap: int = 200):
        """
        Initialize the code chunker.
        
        Args:
            max_chunk_size: Maximum size of a chunk in characters
            overlap: Overlap between chunks in characters
        """
        self.max_chunk_size = max_chunk_size
        self.overlap = overlap
    
    def chunk_by_function(self, content: str, language: Optional[str]) -> List[Dict]:
        """Chunk code by functions or classes based on language-specific patterns."""
        chunks = []
        
        # Define patterns for different languages
        patterns = {
            'python': r'(def\s+\w+\s*\(.*?\)|class\s+\w+\s*(?:\(.*?\))?:)',
            'javascript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|let\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|var\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'typescript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|let\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|var\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'java': r'(public|private|protected)?\s+(static)?\s+\w+\s+\w+\s*\(.*?\)|class\s+\w+',
            'cpp': r'(\w+\s+\w+\s*\(.*?\))|class\s+\w+',
        }
        
        if language and language in patterns:
            pattern = patterns[language]
            # Find all matches
            matches = list(re.finditer(pattern, content, re.DOTALL))
            
            if matches:
                for i, match in enumerate(matches):
                    start = match.start()
                    
                    # Determine end of the function/class
                    if i < len(matches) - 1:
                        end = matches[i + 1].start()
                    else:
                        end = len(content)
                    
                    chunk_content = content[start:end]
                    
                    # If chunk is too large, further split it
                    if len(chunk_content) > self.max_chunk_size:
                        sub_chunks = self.chunk_by_size(chunk_content)
                        for sub_chunk in sub_chunks:
                            chunks.append({
                                'content': sub_chunk,
                                'type': 'function_part',
                                'start': start,
                                'end': start + len(sub_chunk)
                            })
                    else:
                        chunks.append({
                            'content': chunk_content,
                            'type': 'function',
                            'start': start,
                            'end': end
                        })
                
                return chunks
        
        # Fall back to size-based chunking if language not supported or no functions found
        return self.chunk_by_size(content)
    
    def chunk_by_size(self, content: str) -> List[Dict]:
        """Chunk code by size with overlap."""
        chunks = []
        
        # Try to split on newlines to avoid breaking in the middle of a line
        lines = content.split('\n')
        current_chunk = ""
        current_size = 0
        
        for line in lines:
            line_with_newline = line + '\n'
            line_size = len(line_with_newline)
            
            if current_size + line_size > self.max_chunk_size and current_chunk:
                # Add the current chunk
                chunks.append({
                    'content': current_chunk,
                    'type': 'size_based',
                    'start': 0,  # Approximate
                    'end': 0     # Approximate
                })
                
                # Start a new chunk with overlap
                overlap_lines = current_chunk.split('\n')[-self.overlap//20:]  # Approximate lines for overlap
                current_chunk = '\n'.join(overlap_lines) + '\n' + line_with_newline
                current_size = len(current_chunk)
            else:
                current_chunk += line_with_newline
                current_size += line_size
        
        # Add the last chunk if it's not empty
        if current_chunk:
            chunks.append({
                'content': current_chunk,
                'type': 'size_based',
                'start': 0,  # Approximate
                'end': 0     # Approximate
            })
        
        return chunks
    
    def chunk_file(self, file_data: Dict) -> List[Dict]:
        """Chunk a file into segments."""
        content = file_data['content']
        language = file_data['language']
        
        chunks = self.chunk_by_function(content, language)
        
        # Add file metadata to each chunk
        for chunk in chunks:
            chunk['file_path'] = file_data['path']
            chunk['language'] = language
        
        return chunks
```

## Setting Up Vector Embeddings

Now, we'll set up a system to convert code chunks into vector embeddings:

```python
# code_embedder.py
from typing import List, Dict
from sentence_transformers import SentenceTransformer
import os
import torch

class CodeEmbedder:
    """Embedder for converting code chunks into vector representations."""
    
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        """
        Initialize the code embedder.
        
        Args:
            model_name: Name of the sentence transformer model to use
        """
        # Check if CUDA is available
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print(f"Using device: {self.device}")
        
        # Load the model
        self.model = SentenceTransformer(model_name, device=self.device)
    
    def create_embeddings(self, chunks: List[Dict]) -> List[Dict]:
        """Create embeddings for a list of code chunks."""
        # Extract text from chunks
        texts = [self._prepare_text_for_embedding(chunk) for chunk in chunks]
        
        # Generate embeddings
        embeddings = self.model.encode(texts, show_progress_bar=True)
        
        # Add embeddings to chunks
        for i, chunk in enumerate(chunks):
            chunk['embedding'] = embeddings[i].tolist()
        
        return chunks
    
    def _prepare_text_for_embedding(self, chunk: Dict) -> str:
        """Prepare text for embedding by adding context."""
        text = chunk['content']
        
        # Add file path and language as context
        context = f"File: {chunk['file_path']}, Language: {chunk['language']}\n\n"
        
        return context + text
```

## Building the Vector Database

Next, we'll set up a vector database to store and retrieve our code embeddings:

```python
# vector_store.py
from typing import List, Dict, Optional
import chromadb
from chromadb.config import Settings
import os
import json
import uuid

class VectorStore:
    """Vector database for storing and retrieving code embeddings."""
    
    def __init__(self, persist_directory: str = "./code_index"):
        """
        Initialize the vector store.
        
        Args:
            persist_directory: Directory to persist the database
        """
        self.persist_directory = persist_directory
        os.makedirs(persist_directory, exist_ok=True)
        
        # Initialize ChromaDB
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection("code_chunks")
    
    def add_chunks(self, chunks: List[Dict]):
        """Add chunks to the vector store."""
        # Prepare data for ChromaDB
        ids = [str(uuid.uuid4()) for _ in chunks]
        documents = [chunk['content'] for chunk in chunks]
        embeddings = [chunk['embedding'] for chunk in chunks]
        metadatas = []
        
        for chunk in chunks:
            metadata = {
                'file_path': chunk['file_path'],
                'language': chunk['language'],
                'type': chunk['type'],
                'start': chunk.get('start', 0),
                'end': chunk.get('end', 0)
            }
            metadatas.append(metadata)
        
        # Add to ChromaDB
        self.collection.add(
            ids=ids,
            documents=documents,
            embeddings=embeddings,
            metadatas=metadatas
        )
    
    def search(self, query: str, n_results: int = 5, filter_criteria: Optional[Dict] = None) -> List[Dict]:
        """
        Search for relevant code chunks.
        
        Args:
            query: The search query
            n_results: Number of results to return
            filter_criteria: Filter criteria for the search
        
        Returns:
            List of relevant code chunks
        """
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results,
            where=filter_criteria
        )
        
        # Format results
        formatted_results = []
        for i in range(len(results['documents'][0])):
            formatted_results.append({
                'content': results['documents'][0][i],
                'metadata': results['metadatas'][0][i],
                'distance': results['distances'][0][i] if 'distances' in results else None
            })
        
        return formatted_results
```

## Creating the Main Indexer

Now, let's tie everything together with a main indexer class:

```python
# main.py
from code_parser import CodeParser
from code_chunker import CodeChunker
from code_embedder import CodeEmbedder
from vector_store import VectorStore
from typing import List, Dict, Optional
import argparse
import os
import json
from tqdm import tqdm
import time

class CodeIndexer:
    """Main class for indexing code repositories."""
    
    def __init__(
        self,
        repo_path: str,
        output_dir: str = "./code_index",
        max_chunk_size: int = 1000,
        overlap: int = 200,
        embedding_model: str = "all-MiniLM-L6-v2"
    ):
        """
        Initialize the code indexer.
        
        Args:
            repo_path: Path to the repository
            output_dir: Directory to store the index
            max_chunk_size: Maximum size of a chunk in characters
            overlap: Overlap between chunks in characters
            embedding_model: Name of the embedding model to use
        """
        self.repo_path = repo_path
        self.output_dir = output_dir
        
        # Initialize components
        self.parser = CodeParser(repo_path)
        self.chunker = CodeChunker(max_chunk_size, overlap)
        self.embedder = CodeEmbedder(embedding_model)
        self.vector_store = VectorStore(output_dir)
    
    def index_repository(self):
        """Index the entire repository."""
        print(f"Indexing repository: {self.repo_path}")
        
        # Parse files
        print("Parsing files...")
        parsed_files = self.parser.parse_repository()
        print(f"Found {len(parsed_files)} files")
        
        # Process files in batches to avoid memory issues
        batch_size = 10
        for i in range(0, len(parsed_files), batch_size):
            batch = parsed_files[i:i+batch_size]
            
            # Chunk files
            print(f"Chunking batch {i//batch_size + 1}/{(len(parsed_files)-1)//batch_size + 1}...")
            all_chunks = []
            for file_data in tqdm(batch):
                chunks = self.chunker.chunk_file(file_data)
                all_chunks.extend(chunks)
            
            # Create embeddings
            print(f"Creating embeddings for {len(all_chunks)} chunks...")
            chunks_with_embeddings = self.embedder.create_embeddings(all_chunks)
            
            # Add to vector store
            print("Adding to vector store...")
            self.vector_store.add_chunks(chunks_with_embeddings)
        
        print(f"Indexing complete. Index stored in {self.output_dir}")
    
    def search(self, query: str, n_results: int = 5, filter_criteria: Optional[Dict] = None):
        """Search the index."""
        return self.vector_store.search(query, n_results, filter_criteria)

def main():
    parser = argparse.ArgumentParser(description="Index a code repository")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--output-dir", default="./code_index", help="Directory to store the index")
    parser.add_argument("--max-chunk-size", type=int, default=1000, help="Maximum size of a chunk in characters")
    parser.add_argument("--overlap", type=int, default=200, help="Overlap between chunks in characters")
    parser.add_argument("--embedding-model", default="all-MiniLM-L6-v2", help="Name of the embedding model to use")
    
    args = parser.parse_args()
    
    indexer = CodeIndexer(
        args.repo_path,
        args.output_dir,
        args.max_chunk_size,
        args.overlap,
        args.embedding_model
    )
    
    indexer.index_repository()

if __name__ == "__main__":
    main()
```

## Testing the Indexer

Let's create a simple test script to verify our indexer works:

```python
# test_indexer.py
from main import CodeIndexer
import argparse

def main():
    parser = argparse.ArgumentParser(description="Test the code indexer")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--index-dir", default="./code_index", help="Directory where the index is stored")
    parser.add_argument("--query", default="function to calculate fibonacci", help="Query to search for")
    parser.add_argument("--n-results", type=int, default=3, help="Number of results to return")
    
    args = parser.parse_args()
    
    # Create indexer with existing index
    indexer = CodeIndexer(args.repo_path, args.index_dir)
    
    # Search
    results = indexer.search(args.query, args.n_results)
    
    # Print results
    print(f"Results for query: '{args.query}'")
    print("=" * 80)
    
    for i, result in enumerate(results):
        print(f"Result {i+1}:")
        print(f"File: {result['metadata']['file_path']}")
        print(f"Language: {result['metadata']['language']}")
        print(f"Relevance: {1 - result['distance'] if result['distance'] is not None else 'N/A'}")
        print("-" * 40)
        print(result['content'][:500] + "..." if len(result['content']) > 500 else result['content'])
        print("=" * 80)

if __name__ == "__main__":
    main()
```

## Running the Indexer

Now you can run the indexer on your codebase:

```bash
# Index a repository
python main.py /path/to/your/repo --output-dir ./my_code_index

# Test the indexer
python test_indexer.py /path/to/your/repo --index-dir ./my_code_index --query "function to calculate fibonacci"
```

## Next Steps

You've now built a complete code indexing system that can:
1. Parse code files from a repository
2. Break them into meaningful chunks
3. Convert those chunks into vector embeddings
4. Store them in a vector database for efficient retrieval

In the next guide, we'll build a Retrieval-Augmented Generation (RAG) system that uses this index to provide context-aware responses to coding questions.

Continue to [Implementing a Retrieval-Augmented Generation (RAG) System](04-implementing-rag-system.md).
