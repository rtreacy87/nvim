# Building a Code Understanding System

A key component of our local AI coding assistant is a robust code understanding system. This system will parse, analyze, and index your codebase, then use that information to provide context-aware assistance. In this guide, we'll build a complete code understanding system using Python.

## Understanding Code Indexing and RAG

Our code understanding system combines two key components:

1. **Code Indexing**: Parsing and converting code into searchable vector embeddings
2. **Retrieval-Augmented Generation (RAG)**: Using the indexed code to provide context for the LLM

This approach allows the AI to:
- Find relevant code snippets based on semantic meaning
- Understand relationships between different parts of the codebase
- Provide context-aware completions and answers

## Setting Up the Project Structure

Let's start by setting up our project structure:

```bash
mkdir -p local-ai-assistant/code-understanding
cd local-ai-assistant/code-understanding
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

Now, let's install the required packages:

```bash
pip install langchain langchain-community sentence-transformers chromadb pydantic tqdm gitpython requests python-dotenv
```

## Building the Code Indexing System

### 1. Code Parser

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
        """Initialize the code parser."""
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

### 2. Code Chunker and Embedder

Next, we'll implement a chunking strategy and embedding system:

```python
# code_processor.py
from typing import List, Dict, Optional
import re
from sentence_transformers import SentenceTransformer
import torch

class CodeChunker:
    """Chunker for breaking code into meaningful segments."""
    
    def __init__(self, max_chunk_size: int = 1000, overlap: int = 200):
        """Initialize the code chunker."""
        self.max_chunk_size = max_chunk_size
        self.overlap = overlap
    
    def chunk_file(self, file_data: Dict) -> List[Dict]:
        """Chunk a file into segments."""
        content = file_data['content']
        language = file_data['language']
        
        # Try to chunk by function/class first
        chunks = self._chunk_by_function(content, language)
        
        # If no chunks were created, fall back to size-based chunking
        if not chunks:
            chunks = self._chunk_by_size(content)
        
        # Add file metadata to each chunk
        for chunk in chunks:
            chunk['file_path'] = file_data['path']
            chunk['language'] = language
        
        return chunks
    
    def _chunk_by_function(self, content: str, language: Optional[str]) -> List[Dict]:
        """Chunk code by functions or classes based on language-specific patterns."""
        chunks = []
        
        # Define patterns for different languages
        patterns = {
            'python': r'(def\s+\w+\s*\(.*?\)|class\s+\w+\s*(?:\(.*?\))?:)',
            'javascript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'typescript': r'(function\s+\w+\s*\(.*?\)|class\s+\w+|const\s+\w+\s*=\s*(?:function)?\s*\(.*?\))',
            'java': r'(public|private|protected)?\s+(static)?\s+\w+\s+\w+\s*\(.*?\)|class\s+\w+',
        }
        
        if language and language in patterns:
            pattern = patterns[language]
            matches = list(re.finditer(pattern, content, re.DOTALL))
            
            if matches:
                for i, match in enumerate(matches):
                    start = match.start()
                    end = matches[i + 1].start() if i < len(matches) - 1 else len(content)
                    chunk_content = content[start:end]
                    
                    chunks.append({
                        'content': chunk_content,
                        'type': 'function',
                        'start': start,
                        'end': end
                    })
        
        return chunks
    
    def _chunk_by_size(self, content: str) -> List[Dict]:
        """Chunk code by size with overlap."""
        chunks = []
        lines = content.split('\n')
        current_chunk = ""
        
        for line in lines:
            line_with_newline = line + '\n'
            
            if len(current_chunk) + len(line_with_newline) > self.max_chunk_size and current_chunk:
                chunks.append({
                    'content': current_chunk,
                    'type': 'size_based',
                })
                
                # Start a new chunk with overlap
                overlap_lines = current_chunk.split('\n')[-self.overlap//20:]
                current_chunk = '\n'.join(overlap_lines) + '\n' + line_with_newline
            else:
                current_chunk += line_with_newline
        
        # Add the last chunk
        if current_chunk:
            chunks.append({
                'content': current_chunk,
                'type': 'size_based',
            })
        
        return chunks

class CodeEmbedder:
    """Embedder for converting code chunks into vector representations."""
    
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        """Initialize the code embedder."""
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print(f"Using device: {self.device}")
        self.model = SentenceTransformer(model_name, device=self.device)
    
    def create_embeddings(self, chunks: List[Dict]) -> List[Dict]:
        """Create embeddings for a list of code chunks."""
        texts = [self._prepare_text_for_embedding(chunk) for chunk in chunks]
        embeddings = self.model.encode(texts, show_progress_bar=True)
        
        for i, chunk in enumerate(chunks):
            chunk['embedding'] = embeddings[i].tolist()
        
        return chunks
    
    def _prepare_text_for_embedding(self, chunk: Dict) -> str:
        """Prepare text for embedding by adding context."""
        text = chunk['content']
        context = f"File: {chunk['file_path']}, Language: {chunk['language']}\n\n"
        return context + text
```

### 3. Vector Database

Next, we'll set up a vector database to store and retrieve our code embeddings:

```python
# vector_store.py
from typing import List, Dict, Optional
import chromadb
import os
import uuid

class VectorStore:
    """Vector database for storing and retrieving code embeddings."""
    
    def __init__(self, persist_directory: str = "./code_index"):
        """Initialize the vector store."""
        self.persist_directory = persist_directory
        os.makedirs(persist_directory, exist_ok=True)
        
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection("code_chunks")
    
    def add_chunks(self, chunks: List[Dict]):
        """Add chunks to the vector store."""
        ids = [str(uuid.uuid4()) for _ in chunks]
        documents = [chunk['content'] for chunk in chunks]
        embeddings = [chunk['embedding'] for chunk in chunks]
        metadatas = []
        
        for chunk in chunks:
            metadata = {
                'file_path': chunk['file_path'],
                'language': chunk['language'],
                'type': chunk['type'],
            }
            metadatas.append(metadata)
        
        self.collection.add(
            ids=ids,
            documents=documents,
            embeddings=embeddings,
            metadatas=metadatas
        )
    
    def search(self, query: str, n_results: int = 5, filter_criteria: Optional[Dict] = None) -> List[Dict]:
        """Search for relevant code chunks."""
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results,
            where=filter_criteria
        )
        
        formatted_results = []
        for i in range(len(results['documents'][0])):
            formatted_results.append({
                'content': results['documents'][0][i],
                'metadata': results['metadatas'][0][i],
                'distance': results['distances'][0][i] if 'distances' in results else None
            })
        
        return formatted_results
```

### 4. Main Indexer

Now, let's tie everything together with a main indexer class:

```python
# indexer.py
from code_parser import CodeParser
from code_processor import CodeChunker, CodeEmbedder
from vector_store import VectorStore
from typing import List, Dict, Optional
import argparse
from tqdm import tqdm

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
        """Initialize the code indexer."""
        self.repo_path = repo_path
        self.output_dir = output_dir
        
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
        
        # Process files in batches
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
```

## Building the RAG System

Now, let's build a RAG system that uses our code index to provide context-aware responses:

### 1. Query Processor

```python
# query_processor.py
from typing import Dict
import re

class QueryProcessor:
    """Processor for transforming user queries into effective search queries."""
    
    def __init__(self):
        """Initialize the query processor."""
        self.patterns = {
            'code_completion': r'complete|finish|continue|write the rest',
            'code_explanation': r'explain|understand|how does|what does|why does',
            'code_search': r'find|search|locate|where is|show me',
            'code_fix': r'fix|debug|error|issue|problem|not working',
            'code_refactor': r'refactor|improve|optimize|clean|better way'
        }
    
    def process_query(self, query: str) -> Dict:
        """Process a user query to determine its type and create an optimized search query."""
        query_type = self._determine_query_type(query)
        optimized_query = self._optimize_query(query, query_type)
        
        return {
            'original_query': query,
            'query_type': query_type,
            'optimized_query': optimized_query
        }
    
    def _determine_query_type(self, query: str) -> str:
        """Determine the type of query based on patterns."""
        query_lower = query.lower()
        
        for query_type, pattern in self.patterns.items():
            if re.search(pattern, query_lower):
                return query_type
        
        return 'code_search'
    
    def _optimize_query(self, query: str, query_type: str) -> str:
        """Optimize the query based on its type."""
        query = re.sub(r'can you |please |I want to |I need to |show me |tell me about ', '', query, flags=re.IGNORECASE)
        
        if query_type == 'code_completion':
            query = re.sub(r'complete|finish|continue|write the rest', '', query, flags=re.IGNORECASE).strip()
        elif query_type == 'code_explanation':
            query = re.sub(r'explain|understand|how does|what does|why does', '', query, flags=re.IGNORECASE).strip()
        elif query_type == 'code_fix':
            query = re.sub(r'fix|debug|solve', '', query, flags=re.IGNORECASE).strip()
        
        return query
```

### 2. Prompt Constructor and Response Generator

```python
# rag_components.py
from typing import Dict, Optional
import requests

class PromptConstructor:
    """Constructor for building effective prompts for the LLM."""
    
    def __init__(self):
        """Initialize the prompt constructor."""
        self.base_prompts = {
            'code_completion': "Complete the following code based on the context provided:",
            'code_explanation': "Explain the following code in detail, describing what it does and how it works:",
            'code_search': "Based on the code context provided, answer the following question:",
            'code_fix': "Identify and fix the issues in the following code:",
            'code_refactor': "Suggest improvements or refactoring for the following code:"
        }
    
    def construct_prompt(
        self,
        query: str,
        context: Dict,
        query_type: str,
        current_file: Optional[str] = None,
        current_code: Optional[str] = None
    ) -> str:
        """Construct a prompt for the LLM."""
        base_prompt = self.base_prompts.get(query_type, self.base_prompts['code_search'])
        
        system_instruction = (
            "You are an AI coding assistant with expertise in programming. "
            "Your task is to provide helpful, accurate, and concise responses to coding questions. "
            "Base your responses on the code context provided, and when appropriate, include code examples. "
            "Always explain your reasoning clearly."
        )
        
        prompt = f"{system_instruction}\n\n"
        prompt += "CONTEXT FROM CODEBASE:\n"
        prompt += context['combined_context']
        prompt += "\n\n"
        
        if current_file and current_code:
            prompt += f"CURRENT FILE: {current_file}\n\n"
            prompt += f"```\n{current_code}\n```\n\n"
        
        prompt += f"{base_prompt}\n\n"
        prompt += f"USER QUERY: {query}\n\n"
        
        return prompt

class ResponseGenerator:
    """Generator for creating responses using Ollama."""
    
    def __init__(self, base_url: str = "http://localhost:11434"):
        """Initialize the response generator."""
        self.base_url = base_url
        self.api_generate = f"{base_url}/api/generate"
    
    def generate_response(
        self,
        prompt: str,
        model: str = "code-assistant",
        temperature: float = 0.2,
        max_tokens: int = 2000,
        query_type: Optional[str] = None
    ) -> Dict:
        """Generate a response using Ollama."""
        if query_type == 'code_completion':
            temperature = 0.1
        elif query_type == 'code_explanation':
            temperature = 0.3
        
        data = {
            "model": model,
            "prompt": prompt,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": False
        }
        
        try:
            response = requests.post(self.api_generate, json=data)
            response.raise_for_status()
            result = response.json()
            
            return {
                'response': result['response'],
                'model': model,
                'query_type': query_type
            }
        
        except Exception as e:
            return {
                'error': str(e),
                'response': f"Error generating response: {str(e)}",
                'model': model,
                'query_type': query_type
            }
```

### 3. Main RAG System

```python
# rag_system.py
from indexer import CodeIndexer
from query_processor import QueryProcessor
from rag_components import PromptConstructor, ResponseGenerator
from typing import Dict, Optional, List
import argparse

class CodeRAG:
    """Main class for the code RAG system."""
    
    def __init__(
        self,
        repo_path: str,
        index_dir: str = "./code_index",
        model: str = "code-assistant",
        ollama_base_url: str = "http://localhost:11434"
    ):
        """Initialize the code RAG system."""
        self.repo_path = repo_path
        self.model = model
        
        self.indexer = CodeIndexer(repo_path, index_dir)
        self.query_processor = QueryProcessor()
        self.prompt_constructor = PromptConstructor()
        self.response_generator = ResponseGenerator(ollama_base_url)
    
    def retrieve_context(self, query: str, n_results: int = 5) -> Dict:
        """Retrieve relevant context for a query."""
        results = self.indexer.search(query, n_results)
        
        context_parts = []
        for i, result in enumerate(results):
            file_path = result['metadata']['file_path']
            language = result['metadata']['language']
            content = result['content']
            
            context_part = f"[{i+1}] File: {file_path} (Language: {language})\n\n```{language}\n{content}\n```\n\n"
            context_parts.append(context_part)
        
        combined_context = "\n".join(context_parts)
        
        return {
            'query': query,
            'results': results,
            'combined_context': combined_context
        }
    
    def process_query(
        self,
        query: str,
        n_results: int = 5,
        current_file: Optional[str] = None,
        current_code: Optional[str] = None
    ) -> Dict:
        """Process a user query and generate a response."""
        processed_query = self.query_processor.process_query(query)
        query_type = processed_query['query_type']
        optimized_query = processed_query['optimized_query']
        
        context = self.retrieve_context(optimized_query, n_results)
        
        prompt = self.prompt_constructor.construct_prompt(
            query,
            context,
            query_type,
            current_file,
            current_code
        )
        
        response = self.response_generator.generate_response(
            prompt,
            self.model,
            query_type=query_type
        )
        
        response['original_query'] = query
        response['processed_query'] = processed_query
        response['context_count'] = len(context['results'])
        
        return response
```

## Running the System

Let's create a simple script to run our code understanding system:

```python
# main.py
from indexer import CodeIndexer
from rag_system import CodeRAG
import argparse

def main():
    parser = argparse.ArgumentParser(description="Code Understanding System")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--index-dir", default="./code_index", help="Directory to store the index")
    parser.add_argument("--model", default="code-assistant", help="The model to use for generation")
    parser.add_argument("--index", action="store_true", help="Index the repository")
    parser.add_argument("--query", help="Query to process")
    
    args = parser.parse_args()
    
    # Index the repository if requested
    if args.index:
        indexer = CodeIndexer(args.repo_path, args.index_dir)
        indexer.index_repository()
    
    # Create the RAG system
    rag = CodeRAG(args.repo_path, args.index_dir, args.model)
    
    # Process the query if provided
    if args.query:
        response = rag.process_query(args.query)
        print(f"Query: {args.query}")
        print(f"Query Type: {response['processed_query']['query_type']}")
        print(f"Context Count: {response['context_count']}")
        print("\nResponse:")
        print(response['response'])
    else:
        # Interactive mode
        print("Code Understanding System")
        print("Type 'exit' to quit")
        print("=" * 80)
        
        while True:
            query = input("\nEnter your query: ")
            if query.lower() == 'exit':
                break
            
            response = rag.process_query(query)
            print("\nResponse:")
            print("-" * 80)
            print(response['response'])
            print("=" * 80)

if __name__ == "__main__":
    main()
```

## Next Steps

You've now built a complete code understanding system that can:
1. Parse and index your codebase
2. Retrieve relevant code context for queries
3. Generate context-aware responses to coding questions

In the next guide, we'll develop a Neovim integration that will allow you to use this system directly from your editor.

Continue to [Neovim Integration](04-neovim-integration.md).
