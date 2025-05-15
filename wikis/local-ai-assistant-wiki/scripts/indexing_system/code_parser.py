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