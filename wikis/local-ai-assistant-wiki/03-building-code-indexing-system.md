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

Let's start by setting up our project structure with a proper development environment:

```bash
# Create project directory with a descriptive name
mkdir -p local-ai-assistant/code-indexer
cd local-ai-assistant/code-indexer
```

### Setting Up the Development Environment

You can choose between a standard Python virtual environment or Conda, depending on your preference:

#### Option 1: Standard Python Virtual Environment

```bash
# Create a virtual environment with a descriptive name
python -m venv code-indexer-env

# Activate the virtual environment
# On Windows:
code-indexer-env\Scripts\activate
# On macOS/Linux:
source code-indexer-env/bin/activate
```

#### Option 2: Using Conda Environment

If you prefer using Conda for environment management:

```bash
# Create a new conda environment
conda create -n code-indexer-env python=3.10

# Activate the conda environment
conda activate code-indexer-env
```

### Installing Required Packages

Once your environment is activated, install the necessary packages:

```bash
# For either environment type
pip install langchain langchain-community sentence-transformers chromadb pydantic tqdm gitpython
```

## Creating the Code Parser

First, we'll create a code parser that can handle different programming languages:

The CodeParser is the first component in our code indexing pipeline:

    +----------------+     +----------------+     +----------------+     +----------------+
    |                |     |                |     |                |     |                |
    |  Code Parser   | --> |  Code Chunker  | --> | Code Embedder  | --> |  Vector Store  |
    |                |     |                |     |                |     |                |
    +----------------+     +----------------+     +----------------+     +----------------+
          ^
          |
    +----------------+
    |                |
    |   Repository   |
    |                |
    +----------------+

The CodeParser handles:
- Walking through repository directories
- Filtering out non-code files using ignore patterns
- Identifying programming languages based on file extensions
- Reading file contents and extracting metadata

```python
# code_parser.py
import os
from typing import List, Dict, Optional
from pathlib import Path
import fnmatch

class CodeParser:
    """
    Parser for extracting and analyzing code from repositories.
    
    This class handles the first stage of the code indexing pipeline by:
    1. Walking through a repository directory structure
    2. Identifying relevant code files while ignoring non-code files
    3. Determining the programming language of each file
    4. Reading and extracting the content of each file
    
    The parser is designed to be language-agnostic, supporting multiple programming
    languages through extension detection, and configurable through ignore patterns
    to exclude irrelevant files (like binaries, cache files, etc.).
    """
    
    def __init__(self, repo_path: str, ignore_patterns: Optional[List[str]] = None):
        """
        Initialize the code parser with repository path and ignore patterns.
        
        Args:
            repo_path: Path to the repository to be parsed
            ignore_patterns: List of glob patterns for files/directories to ignore
                             (defaults to common non-code files if None)
        """
        self.repo_path = Path(repo_path)
        self.ignore_patterns = ignore_patterns or [
            "*.git/*", "*.pyc", "__pycache__/*", "*.ipynb_checkpoints/*",
            "*.venv/*", "*venv/*", "*node_modules/*", "*.DS_Store",
            "*.idea/*", "*.vscode/*", "*.png", "*.jpg", "*.jpeg", "*.gif",
            "*.svg", "*.ico", "*.pdf", "*.zip", "*.tar.gz", "*.jar"
        ]
    
    def should_ignore(self, file_path: str) -> bool:
        """
        Check if a file should be ignored based on ignore patterns.
        
        This function helps filter out non-code files, build artifacts,
        and other irrelevant files that shouldn't be included in the index.
        
        Args:
            file_path: Relative path of the file to check
            
        Returns:
            True if the file should be ignored, False otherwise
        """
        for pattern in self.ignore_patterns:
            if fnmatch.fnmatch(file_path, pattern):
                return True
        return False
    
    def get_file_language(self, file_path: str) -> Optional[str]:
        """
        Determine the programming language of a file based on its extension.
        
        This function maps file extensions to programming language names,
        which is important for language-specific processing later in the pipeline.
        
        Args:
            file_path: Path to the file
            
        Returns:
            String representing the programming language, or None if unknown
        """
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
        """
        Parse a single file and return its content with metadata.
        
        This function reads the file content and collects important metadata
        such as the file path, language, and size, which will be used in
        subsequent processing steps.
        
        Args:
            file_path: Relative path to the file within the repository
            
        Returns:
            Dictionary containing file content and metadata, or None if parsing fails
        """
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
        """
        Parse all files in the repository.
        
        This is the main entry point for the parser, which orchestrates the process of:
        1. Finding all relevant files in the repository
        2. Parsing each file to extract content and metadata
        
        Returns:
            List of dictionaries, each containing a file's content and metadata
        """
        file_paths = self._get_relevant_file_paths()
        parsed_files = []
        for file_path in file_paths:
            parsed_file = self.parse_file(file_path)
            if parsed_file:
                parsed_files.append(parsed_file)
        return parsed_files

    def _get_relevant_file_paths(self) -> List[str]:
        """
        Get all relevant file paths in the repository.
        
        This helper method walks through the repository directory structure
        and returns paths to all files that should be included in the index.
        
        Returns:
            List of relative file paths
        """
        all_files = self._get_all_files()
        relevant_paths = [path for path in all_files if not self.should_ignore(path)]
        return relevant_paths

    def _get_all_files(self) -> List[str]:
        """
        Get all file paths in the repository.
        
        Returns:
            List of normalized relative file paths
        """
        all_files = []
        
        for root, _, files in os.walk(self.repo_path):
            rel_root = os.path.relpath(root, self.repo_path)
            
            # Create relative paths for all files in this directory
            relative_paths = [os.path.join(rel_root, file) for file in files]
            
            # Normalize all paths
            normalized_paths = [self._normalize_path(path) for path in relative_paths]
            
            # Add to the list of all files
            all_files.extend(normalized_paths)
        
        return all_files

    def _normalize_path(self, path: str) -> str:
        """
        Normalize a path by removing leading './' if present.
        
        Args:
            path: Path to normalize
        
        Returns:
            Normalized path
        """
        if path.startswith('./'):
            return path[2:]
        return path
```

Here's how the methods in the CodeParser class work together:

    +---------------------+
    |   Repository Dir    |
    |  /project           |
    |  ├── src/           |
    |  │   ├── main.py    |
    |  │   └── utils.js   |
    |  ├── node_modules/  |
    |  │   └── lib.js     |
    |  ├── .git/          |
    |  │   └── HEAD       |
    |  ├── image.png      |
    |  └── README.md      |
    +----------+----------+
               |
               v
    +----------+----------+
    |                     |
    |  parse_repository() |
    |                     |
    +----------+----------+
               |
               v
    +----------+----------+
    |                     |
    | _get_relevant_file_ |
    |      paths()        |
    |                     |
    +----------+----------+
               |
               v
    +----------+----------+     +---------------------+
    |                     |     |                     |
    |   _get_all_files()  |---->|   should_ignore()   |
    |                     |     |                     |
    +----------+----------+     +---------------------+
               |                          |
               v                          v
    +----------+----------+     +---------------------+
    |                     |     |  Files to Ignore:   |
    | _normalize_path()   |     |  - node_modules/lib.js
    |                     |     |  - .git/HEAD        |
    +---------------------+     |  - image.png        |
               |                +---------------------+
               |                          |
               |                          v
               |                +---------------------+
               |                |  Files to Keep:     |
               |                |  - src/main.py      |
               |                |  - src/utils.js     |
               |                |  - README.md        |
               |                +----------+----------+
               |                            |
               +----------------------------+
                             |
                             v
                  +----------+----------+
                  |                     |
                  |     parse_file()    |
                  |                     |
                  +----------+----------+
                             |
                             v
                  +----------+----------+
                  |                     |
                  | get_file_language() |
                  |                     |
                  +----------+----------+
                             |
                             v
                  +----------+----------+
                  |  Parsed Files:      |
                  |  [{                 |
                  |    path: 'src/main.py',
                  |    content: '...',  |
                  |    language: 'python',
                  |    size: 1024       |
                  |  },                 |
                  |  {                  |
                  |    path: 'src/utils.js',
                  |    content: '...',  |
                  |    language: 'javascript',
                  |    size: 512        |
                  |  },                 |
                  |  {                  |
                  |    path: 'README.md',
                  |    content: '...',  |
                  |    language: 'markdown',
                  |    size: 256        |
                  |  }]                 |
                  +---------------------+

The workflow is:
1. `parse_repository()` is the main entry point that orchestrates the process
2. It calls `_get_relevant_file_paths()` to get all files that should be processed
3. `_get_relevant_file_paths()` uses `_get_all_files()` and filters with `should_ignore()`
4. `_get_all_files()` walks the directory and uses `_normalize_path()` to standardize paths
5. For each relevant file, `parse_file()` extracts content and metadata
6. `parse_file()` uses `get_file_language()` to determine the programming language
7. The result is a list of parsed files with their content and metadata

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
        pattern = self._get_language_pattern(language)
        if not pattern:
            return self.chunk_by_size(content)
            
        matches = self._find_pattern_matches(pattern, content)
        if not matches:
            return self.chunk_by_size(content)
            
        return self._process_matches(matches, content)
    
    def _get_language_pattern(self, language: Optional[str]) -> Optional[str]:
        """Get the regex pattern for a specific language."""
        patterns = {
            'python': r'(def\s+\w+\s*\(.*?\)|class\s+\w+\s*(?:\(.*?\))?:)',
            'javascript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|let\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|var\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'typescript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|let\s+\w+\s*=\s*(?:function)?\s*\(.*?\)|var\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'java': r'(public|private|protected)?\s+(static)?\s+\w+\s+\w+\s*\(.*?\)|class\s+\w+',
            'cpp': r'(\w+\s+\w+\s*\(.*?\))|class\s+\w+',
        }
        return patterns.get(language) if language else None
    
    def _find_pattern_matches(self, pattern: str, content: str) -> List:
        """Find all matches of the pattern in the content."""
        return list(re.finditer(pattern, content, re.DOTALL))
    
    def _process_matches(self, matches: List, content: str) -> List[Dict]:
        """Process each match to create chunks."""
        chunks = []
        for i, match in enumerate(matches):
            start = match.start()
            end = self._determine_chunk_end(matches, i, content)
            chunk_content = content[start:end]
            
            chunks.extend(self._handle_chunk_content(chunk_content, start, end))
        return chunks
    
    def _handle_chunk_content(self, chunk_content: str, start: int, end: int) -> List[Dict]:
        """Handle chunk content based on its size."""
        if len(chunk_content) > self.max_chunk_size:
            return self._split_large_chunk(chunk_content, start)
        else:
            return [self._create_function_chunk(chunk_content, start, end)]
    
    def _determine_chunk_end(self, matches: List, index: int, content: str) -> int:
        """Determine the end position of a chunk."""
        if index < len(matches) - 1:
            return matches[index + 1].start()
        return len(content)
    
    def _split_large_chunk(self, chunk_content: str, start_pos: int) -> List[Dict]:
        """Split a large chunk into smaller sub-chunks."""
        sub_chunks = []
        size_based_chunks = self.chunk_by_size(chunk_content)
        
        for sub_chunk in size_based_chunks:
            sub_chunks.append({
                'content': sub_chunk['content'],
                'type': 'function_part',
                'start': start_pos,
                'end': start_pos + len(sub_chunk['content'])
            })
        
        return sub_chunks
    
    def _create_function_chunk(self, content: str, start: int, end: int) -> Dict:
        """Create a chunk dictionary for a function."""
        return {
            'content': content,
            'type': 'function',
            'start': start,
            'end': end
        }
    
    def chunk_by_size(self, content: str) -> List[Dict]:
        """Chunk code by size with overlap."""
        lines = self._split_content_into_lines(content)
        chunks = []
        
        current_chunk = ""
        current_size = 0
        
        for line in lines:
            line_with_newline = self._add_newline(line)
            line_size = len(line_with_newline)
            
            if self._should_create_new_chunk(current_size, line_size, current_chunk):
                chunks.append(self._create_size_chunk(current_chunk))
                current_chunk, current_size = self._start_new_chunk_with_overlap(current_chunk, line_with_newline)
            else:
                current_chunk, current_size = self._add_line_to_chunk(current_chunk, current_size, line_with_newline, line_size)
        
        if current_chunk:
            chunks.append(self._create_size_chunk(current_chunk))
        
        return chunks
    
    def _split_content_into_lines(self, content: str) -> List[str]:
        """Split content into lines to avoid breaking in the middle of a line."""
        return content.split('\n')
    
    def _add_newline(self, line: str) -> str:
        """Add newline character to a line."""
        return line + '\n'
    
    def _should_create_new_chunk(self, current_size: int, line_size: int, current_chunk: str) -> bool:
        """Determine if a new chunk should be created."""
        return current_size + line_size > self.max_chunk_size and current_chunk
    
    def _create_size_chunk(self, content: str) -> Dict:
        """Create a chunk dictionary for a size-based chunk."""
        return {
            'content': content,
            'type': 'size_based',
            'start': 0,  # Approximate
            'end': 0     # Approximate
        }
    
    def _start_new_chunk_with_overlap(self, current_chunk: str, new_line: str) -> tuple:
        """Start a new chunk with overlap from the previous chunk."""
        overlap_lines = current_chunk.split('\n')[-self.overlap//20:]  # Approximate lines for overlap
        new_chunk = '\n'.join(overlap_lines) + '\n' + new_line
        return new_chunk, len(new_chunk)
    
    def _add_line_to_chunk(self, current_chunk: str, current_size: int, line: str, line_size: int) -> tuple:
        """Add a line to the current chunk."""
        return current_chunk + line, current_size + line_size
    
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












