# Implementing a Retrieval-Augmented Generation (RAG) System

Now that we have a code indexing system, we need to build a Retrieval-Augmented Generation (RAG) system that can use this index to provide context-aware responses to coding questions. This guide will walk you through implementing a complete RAG system for our local AI coding assistant.

## Understanding RAG for Code

Retrieval-Augmented Generation combines:

1. **Retrieval**: Finding relevant information from a knowledge base
2. **Generation**: Using an LLM to generate responses based on the retrieved information

For code, this means:
- Retrieving relevant code snippets from our index
- Providing these snippets as context to the LLM
- Generating responses that are informed by the specific codebase

## Setting Up the Project Structure

Let's continue building on our project:

```bash
cd local-ai-assistant
mkdir -p code-rag
cd code-rag
# Activate the virtual environment if not already active
source ../code-indexer/venv/bin/activate  # On Windows: ..\code-indexer\venv\Scripts\activate
```

Install additional required packages:

```bash
pip install langchain langchain-community pydantic python-dotenv
```

## Creating the RAG Components

### 1. Query Processor

First, let's create a query processor that will transform user queries into effective search queries:

```python
# query_processor.py
from typing import List, Dict, Optional
import re

class QueryProcessor:
    """Processor for transforming user queries into effective search queries."""
    
    def __init__(self):
        """Initialize the query processor."""
        # Patterns to identify different types of queries
        self.patterns = {
            'code_completion': r'complete|finish|continue|write the rest',
            'code_explanation': r'explain|understand|how does|what does|why does',
            'code_search': r'find|search|locate|where is|show me',
            'code_fix': r'fix|debug|error|issue|problem|not working',
            'code_refactor': r'refactor|improve|optimize|clean|better way'
        }
    
    def process_query(self, query: str) -> Dict:
        """
        Process a user query to determine its type and create an optimized search query.
        
        Args:
            query: The user's query
        
        Returns:
            Dict containing query type and optimized search query
        """
        # Determine query type
        query_type = self._determine_query_type(query)
        
        # Create optimized search query based on type
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
        
        # Default to code search if no pattern matches
        return 'code_search'
    
    def _optimize_query(self, query: str, query_type: str) -> str:
        """Optimize the query based on its type."""
        # Remove common words and phrases that don't add search value
        query = re.sub(r'can you |please |I want to |I need to |show me |tell me about ', '', query, flags=re.IGNORECASE)
        
        # Add type-specific optimizations
        if query_type == 'code_completion':
            # For completion, focus on the code context
            query = re.sub(r'complete|finish|continue|write the rest', '', query, flags=re.IGNORECASE).strip()
        
        elif query_type == 'code_explanation':
            # For explanation, focus on the code being explained
            query = re.sub(r'explain|understand|how does|what does|why does', '', query, flags=re.IGNORECASE).strip()
        
        elif query_type == 'code_fix':
            # For fixes, focus on the error or issue
            query = re.sub(r'fix|debug|solve', '', query, flags=re.IGNORECASE).strip()
            # Extract error messages if present (usually in quotes or after "error:")
            error_match = re.search(r'"([^"]+)"|\'([^\']+)\'|error:\s*(.+)', query)
            if error_match:
                error_msg = next(filter(None, error_match.groups()))
                query = error_msg
        
        return query
```

### 2. Context Retriever

Next, let's create a context retriever that will fetch relevant code from our index:

```python
# context_retriever.py
import sys
import os
from typing import List, Dict, Optional
import json

# Add the code-indexer directory to the path so we can import from it
sys.path.append(os.path.abspath('../code-indexer'))
from main import CodeIndexer

class ContextRetriever:
    """Retriever for fetching relevant code context from the index."""
    
    def __init__(self, repo_path: str, index_dir: str = "../code-indexer/code_index"):
        """
        Initialize the context retriever.
        
        Args:
            repo_path: Path to the repository
            index_dir: Directory where the index is stored
        """
        self.indexer = CodeIndexer(repo_path, index_dir)
    
    def retrieve_context(
        self,
        query: str,
        n_results: int = 5,
        filter_criteria: Optional[Dict] = None,
        query_type: Optional[str] = None
    ) -> Dict:
        """
        Retrieve relevant context for a query.
        
        Args:
            query: The search query
            n_results: Number of results to return
            filter_criteria: Filter criteria for the search
            query_type: Type of query (affects retrieval strategy)
        
        Returns:
            Dict containing retrieved context and metadata
        """
        # Adjust n_results based on query type
        if query_type == 'code_completion':
            # For completion, we want fewer but more relevant results
            n_results = min(n_results, 3)
        elif query_type == 'code_explanation':
            # For explanation, we want more context
            n_results = max(n_results, 5)
        
        # Retrieve results from the index
        results = self.indexer.search(query, n_results, filter_criteria)
        
        # Format the context
        context_parts = []
        for i, result in enumerate(results):
            file_path = result['metadata']['file_path']
            language = result['metadata']['language']
            content = result['content']
            
            # Format the context part
            context_part = f"[{i+1}] File: {file_path} (Language: {language})\n\n```{language}\n{content}\n```\n\n"
            context_parts.append(context_part)
        
        # Combine all context parts
        combined_context = "\n".join(context_parts)
        
        return {
            'query': query,
            'results': results,
            'combined_context': combined_context
        }
```

### 3. Prompt Constructor

Now, let's create a prompt constructor that will build effective prompts for the LLM:

```python
# prompt_constructor.py
from typing import Dict, Optional

class PromptConstructor:
    """Constructor for building effective prompts for the LLM."""
    
    def __init__(self):
        """Initialize the prompt constructor."""
        # Base prompts for different query types
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
        """
        Construct a prompt for the LLM.
        
        Args:
            query: The user's query
            context: The retrieved context
            query_type: The type of query
            current_file: The file currently being edited (if any)
            current_code: The code currently being edited (if any)
        
        Returns:
            A formatted prompt for the LLM
        """
        # Get the base prompt for the query type
        base_prompt = self.base_prompts.get(query_type, self.base_prompts['code_search'])
        
        # Build the system instruction
        system_instruction = (
            "You are an AI coding assistant with expertise in programming. "
            "Your task is to provide helpful, accurate, and concise responses to coding questions. "
            "Base your responses on the code context provided, and when appropriate, include code examples. "
            "Always explain your reasoning clearly."
        )
        
        # Add query-specific instructions
        if query_type == 'code_completion':
            system_instruction += (
                " For code completion, continue the code in a way that matches the style and purpose of the existing code. "
                "Make sure your completion is syntactically correct and follows best practices."
            )
        elif query_type == 'code_explanation':
            system_instruction += (
                " For code explanation, break down the code into logical components and explain each part. "
                "Highlight any important patterns, algorithms, or design choices."
            )
        elif query_type == 'code_fix':
            system_instruction += (
                " For code fixes, clearly identify the issues, explain why they are problematic, "
                "and provide corrected code with explanations of the changes."
            )
        
        # Construct the full prompt
        prompt = f"{system_instruction}\n\n"
        
        # Add context from the codebase
        prompt += "CONTEXT FROM CODEBASE:\n"
        prompt += context['combined_context']
        prompt += "\n\n"
        
        # Add current file and code if provided
        if current_file and current_code:
            prompt += f"CURRENT FILE: {current_file}\n\n"
            prompt += f"```\n{current_code}\n```\n\n"
        
        # Add the query and instruction
        prompt += f"{base_prompt}\n\n"
        prompt += f"USER QUERY: {query}\n\n"
        
        return prompt
```

### 4. Response Generator

Next, let's create a response generator that will use Ollama to generate responses:

```python
# response_generator.py
import requests
import json
from typing import Dict, Optional

class ResponseGenerator:
    """Generator for creating responses using Ollama."""
    
    def __init__(self, base_url: str = "http://localhost:11434"):
        """
        Initialize the response generator.
        
        Args:
            base_url: Base URL for the Ollama API
        """
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
        """
        Generate a response using Ollama.
        
        Args:
            prompt: The prompt for the LLM
            model: The model to use
            temperature: The temperature for generation
            max_tokens: The maximum number of tokens to generate
            query_type: The type of query (affects generation parameters)
        
        Returns:
            Dict containing the generated response and metadata
        """
        # Adjust parameters based on query type
        if query_type == 'code_completion':
            # Lower temperature for more deterministic completions
            temperature = 0.1
        elif query_type == 'code_explanation':
            # Higher temperature for more detailed explanations
            temperature = 0.3
        
        # Prepare the request
        data = {
            "model": model,
            "prompt": prompt,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": False
        }
        
        try:
            # Send the request to Ollama
            response = requests.post(self.api_generate, json=data)
            response.raise_for_status()
            
            # Parse the response
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

### 5. Main RAG System

Finally, let's tie everything together with a main RAG system class:

```python
# main.py
from query_processor import QueryProcessor
from context_retriever import ContextRetriever
from prompt_constructor import PromptConstructor
from response_generator import ResponseGenerator
from typing import Dict, Optional
import argparse
import json
import os

class CodeRAG:
    """Main class for the code RAG system."""
    
    def __init__(
        self,
        repo_path: str,
        index_dir: str = "../code-indexer/code_index",
        model: str = "code-assistant",
        ollama_base_url: str = "http://localhost:11434"
    ):
        """
        Initialize the code RAG system.
        
        Args:
            repo_path: Path to the repository
            index_dir: Directory where the index is stored
            model: The model to use for generation
            ollama_base_url: Base URL for the Ollama API
        """
        self.repo_path = repo_path
        self.model = model
        
        # Initialize components
        self.query_processor = QueryProcessor()
        self.context_retriever = ContextRetriever(repo_path, index_dir)
        self.prompt_constructor = PromptConstructor()
        self.response_generator = ResponseGenerator(ollama_base_url)
    
    def process_query(
        self,
        query: str,
        n_results: int = 5,
        filter_criteria: Optional[Dict] = None,
        current_file: Optional[str] = None,
        current_code: Optional[str] = None
    ) -> Dict:
        """
        Process a user query and generate a response.
        
        Args:
            query: The user's query
            n_results: Number of results to retrieve
            filter_criteria: Filter criteria for the search
            current_file: The file currently being edited (if any)
            current_code: The code currently being edited (if any)
        
        Returns:
            Dict containing the generated response and metadata
        """
        # Process the query
        processed_query = self.query_processor.process_query(query)
        query_type = processed_query['query_type']
        optimized_query = processed_query['optimized_query']
        
        # Retrieve context
        context = self.context_retriever.retrieve_context(
            optimized_query,
            n_results,
            filter_criteria,
            query_type
        )
        
        # Construct prompt
        prompt = self.prompt_constructor.construct_prompt(
            query,
            context,
            query_type,
            current_file,
            current_code
        )
        
        # Generate response
        response = self.response_generator.generate_response(
            prompt,
            self.model,
            query_type=query_type
        )
        
        # Add metadata to the response
        response['original_query'] = query
        response['processed_query'] = processed_query
        response['context_count'] = len(context['results'])
        
        return response

def main():
    parser = argparse.ArgumentParser(description="Code RAG System")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--index-dir", default="../code-indexer/code_index", help="Directory where the index is stored")
    parser.add_argument("--model", default="code-assistant", help="The model to use for generation")
    parser.add_argument("--query", help="Query to process")
    
    args = parser.parse_args()
    
    # Create the RAG system
    rag = CodeRAG(args.repo_path, args.index_dir, args.model)
    
    # Process the query if provided
    if args.query:
        response = rag.process_query(args.query)
        print(json.dumps(response, indent=2))
    else:
        # Interactive mode
        print("Code RAG System")
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

## Testing the RAG System

Let's create a simple test script to verify our RAG system works:

```python
# test_rag.py
from main import CodeRAG
import argparse
import json

def main():
    parser = argparse.ArgumentParser(description="Test the Code RAG System")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--index-dir", default="../code-indexer/code_index", help="Directory where the index is stored")
    parser.add_argument("--model", default="code-assistant", help="The model to use for generation")
    
    args = parser.parse_args()
    
    # Create the RAG system
    rag = CodeRAG(args.repo_path, args.index_dir, args.model)
    
    # Test queries
    test_queries = [
        "How does the authentication system work?",
        "Complete the function that calculates fibonacci numbers",
        "Fix the error in the user registration code",
        "Explain the data processing pipeline",
        "Refactor the database connection code to be more efficient"
    ]
    
    # Process each query
    for query in test_queries:
        print(f"Query: {query}")
        print("-" * 80)
        
        response = rag.process_query(query)
        
        print(f"Query Type: {response['processed_query']['query_type']}")
        print(f"Optimized Query: {response['processed_query']['optimized_query']}")
        print(f"Context Count: {response['context_count']}")
        print("\nResponse:")
        print(response['response'])
        
        print("=" * 80)
        input("Press Enter to continue...")

if __name__ == "__main__":
    main()
```

## Running the RAG System

Now you can run the RAG system on your codebase:

```bash
# Run in interactive mode
python main.py /path/to/your/repo --index-dir ../code-indexer/my_code_index

# Run with a specific query
python main.py /path/to/your/repo --index-dir ../code-indexer/my_code_index --query "How does the authentication system work?"

# Run the test script
python test_rag.py /path/to/your/repo --index-dir ../code-indexer/my_code_index
```

## Next Steps

You've now built a complete Retrieval-Augmented Generation (RAG) system that can:
1. Process user queries to determine their intent
2. Retrieve relevant code context from your indexed codebase
3. Construct effective prompts for the LLM
4. Generate context-aware responses to coding questions

In the next guide, we'll develop a Neovim integration that will allow you to use this RAG system directly from your editor.

Continue to [Developing the Neovim Integration](05-developing-neovim-integration.md).
