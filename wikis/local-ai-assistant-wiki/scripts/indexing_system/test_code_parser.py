"""
# Code Parser Test Suite

This module contains tests for the CodeParser class, which is responsible for parsing
and processing code files from a repository.

## Test Structure

- `test_normalize_path`: Tests the path normalization functionality
- `test_get_all_files`: Tests file discovery across directories

## Running Tests

Run these tests using pytest:

```bash
pytest test_code_parser.py -v
```

For specific tests:

```bash
pytest test_code_parser.py::test_normalize_path -v
```
"""

import pytest
import os
from pathlib import Path
from code_parser import CodeParser

def test_normalize_path():
    """
    Test the _normalize_path method which removes leading './' from paths.
    
    Cases tested:
    - Path with leading './'
    - Path without leading './'
    - Empty path
    - Just the './' pattern
    """
    parser = CodeParser("dummy/path")
    
    # Test path with leading './'
    assert parser._normalize_path("./some/file.py") == "some/file.py"
    
    # Test path without leading './'
    assert parser._normalize_path("some/file.py") == "some/file.py"
    
    # Test empty path
    assert parser._normalize_path("") == ""
    
    # Test just the './' pattern
    assert parser._normalize_path("./") == ""

def test_get_all_files():
    """
    Test the _get_all_files method which discovers all files in a directory structure.
    
    This test creates a temporary directory structure, runs the file discovery,
    and verifies the correct files are found regardless of platform-specific path formats.
    
    ASCII diagram of test directory structure:
    
    test_repo/
    ├── file1.py
    ├── file2.js
    └── subdir/
        ├── file3.py
        └── nested/
            └── file4.txt
    
    The test verifies that all files are discovered and paths are properly normalized.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory structure
        test_dir = "test_repo"
        os.makedirs(f"{test_dir}/subdir/nested", exist_ok=True)
        
        # Create some empty files
        open(f"{test_dir}/file1.py", "w").close()
        open(f"{test_dir}/file2.js", "w").close()
        open(f"{test_dir}/subdir/file3.py", "w").close()
        open(f"{test_dir}/subdir/nested/file4.txt", "w").close()
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser._get_all_files()
            
            # Normalize the result paths for comparison
            normalized_result = []
            for path in result:
                # Replace backslashes with forward slashes
                path = path.replace('\\', '/')
                # Remove leading './'
                if path.startswith('./'):
                    path = path[2:]
                normalized_result.append(path)
            
            # Check the results
            expected = [
                'file1.py', 
                'file2.js', 
                'subdir/file3.py', 
                'subdir/nested/file4.txt'
            ]
            
            assert sorted(normalized_result) == sorted(expected)
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)

def test_get_relevant_file_paths():
    """
    Test the _get_relevant_file_paths method which filters files based on ignore patterns.
    
    This test creates a temporary directory structure with various files,
    some of which should be ignored based on the default ignore patterns.
    It then verifies that only the relevant files are returned.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory structure
        test_dir = "test_repo"
        os.makedirs(f"{test_dir}/node_modules", exist_ok=True)
        os.makedirs(f"{test_dir}/.git", exist_ok=True)
        os.makedirs(f"{test_dir}/src", exist_ok=True)
        
        # Create some files that should be included
        open(f"{test_dir}/src/main.py", "w").close()
        open(f"{test_dir}/src/utils.js", "w").close()
        open(f"{test_dir}/README.md", "w").close()
        
        # Create some files that should be ignored
        open(f"{test_dir}/node_modules/package.json", "w").close()
        open(f"{test_dir}/.git/HEAD", "w").close()
        open(f"{test_dir}/image.png", "w").close()
        open(f"{test_dir}/src/script.pyc", "w").close()
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser._get_relevant_file_paths()
            
            # Normalize the result paths for comparison
            normalized_result = []
            for path in result:
                # Replace backslashes with forward slashes for cross-platform compatibility
                path = path.replace('\\', '/')
                # Remove leading './' if present
                if path.startswith('./'):
                    path = path[2:]
                normalized_result.append(path)
            
            # Check the results - only non-ignored files should be included
            expected = [
                'src/main.py',
                'src/utils.js',
                'README.md'
            ]
            
            assert sorted(normalized_result) == sorted(expected)
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)

def test_parse_repository():
    """
    Test the parse_repository method which processes all relevant files in a repository.
    
    This test creates a temporary directory structure with various files,
    runs the repository parsing, and verifies that all relevant files are
    correctly parsed with appropriate metadata.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory structure
        test_dir = "test_repo"
        os.makedirs(f"{test_dir}/src", exist_ok=True)
        
        # Create some test files with content
        with open(f"{test_dir}/src/main.py", "w") as f:
            f.write("def main():\n    print('Hello world')")
        with open(f"{test_dir}/src/utils.js", "w") as f:
            f.write("function helper() { return true; }")
        with open(f"{test_dir}/README.md", "w") as f:
            f.write("# Test Repository")
        
        # Create a file that should be ignored
        os.makedirs(f"{test_dir}/node_modules", exist_ok=True)
        with open(f"{test_dir}/node_modules/ignored.js", "w") as f:
            f.write("// This should be ignored")
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser.parse_repository()
            
            # Check the results
            assert len(result) == 3  # Should have 3 files (not the ignored one)
            
            # Normalize the paths for comparison
            normalized_paths = []
            for item in result:
                path = item['path'].replace('\\', '/')
                # Remove leading './' if present
                if path.startswith('./'):
                    path = path[2:]
                normalized_paths.append(path)
            
            # Verify file paths are correct
            expected_paths = ['src/main.py', 'src/utils.js', 'README.md']
            assert sorted(normalized_paths) == sorted(expected_paths)
            
            # Verify languages are detected correctly
            languages = {}
            for item in result:
                path = item['path'].replace('\\', '/')
                if path.startswith('./'):
                    path = path[2:]
                languages[path] = item['language']
                
            assert languages['src/main.py'] == 'python'
            assert languages['src/utils.js'] == 'javascript'
            assert languages['README.md'] == 'markdown'
            
            # Verify content is parsed correctly
            for item in result:
                path = item['path'].replace('\\', '/')
                if path.startswith('./'):
                    path = path[2:]
                    
                if path == 'src/main.py':
                    assert "def main():" in item['content']
                elif path == 'src/utils.js':
                    assert "function helper()" in item['content']
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)

def test_parse_file():
    """
    Test the parse_file method which processes a single file and extracts its content and metadata.
    
    This test creates a temporary file with known content, parses it using the CodeParser,
    and verifies that the returned metadata (path, content, language, size) is correct.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory and file
        test_dir = "test_repo"
        os.makedirs(test_dir, exist_ok=True)
        
        # Create a test file with known content
        test_file_path = "test_file.py"
        test_content = "def test_function():\n    return True"
        
        with open(f"{test_dir}/{test_file_path}", "w") as f:
            f.write(test_content)
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser.parse_file(test_file_path)
            
            # Verify the result
            assert result is not None
            assert result['path'] == test_file_path
            assert result['content'] == test_content
            assert result['language'] == 'python'
            assert result['size'] == len(test_content)
            
            # Test with a non-existent file
            non_existent = parser.parse_file("non_existent.py")
            assert non_existent is None
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)

def test_get_file_language():
    """
    Test the get_file_language method which determines programming language based on file extension.
    
    This test verifies that:
    1. Common file extensions are correctly mapped to their programming languages
    2. Unknown extensions return None
    3. Case insensitivity works for extensions
    """
    parser = CodeParser("dummy/path")
    
    # Test common file extensions
    assert parser.get_file_language("script.py") == "python"
    assert parser.get_file_language("app.js") == "javascript"
    assert parser.get_file_language("styles.css") == "css"
    assert parser.get_file_language("README.md") == "markdown"
    
    # Test case insensitivity
    assert parser.get_file_language("module.PY") == "python"
    assert parser.get_file_language("config.JSON") == "json"
    
    # Test unknown extension
    assert parser.get_file_language("data.unknown") is None
    assert parser.get_file_language("no_extension") is None

def test_should_ignore():
    """
    Test the should_ignore method which determines if a file should be excluded based on ignore patterns.
    
    This test verifies that:
    1. Files matching ignore patterns are correctly identified
    2. Files not matching any pattern are not ignored
    3. Pattern matching works with wildcards and directory structures
    """
    parser = CodeParser("dummy/path")
    
    # Test files that should be ignored
    assert parser.should_ignore(".git/config") == True
    assert parser.should_ignore("node_modules/package.json") == True
    assert parser.should_ignore("__pycache__/module.pyc") == True
    assert parser.should_ignore("image.png") == True
    
    # Test files that should not be ignored
    assert parser.should_ignore("src/main.py") == False
    assert parser.should_ignore("README.md") == False
    assert parser.should_ignore("config.json") == False
    
    # Test with custom ignore patterns
    custom_parser = CodeParser("dummy/path", ignore_patterns=["*.log", "temp/*"])
    assert custom_parser.should_ignore("app.log") == True
    assert custom_parser.should_ignore("temp/cache.txt") == True
    assert custom_parser.should_ignore("src/app.py") == False

def test_init_default_ignore_patterns():
    """
    Test the initialization of CodeParser with default ignore patterns.
    
    This test verifies that:
    1. The repo_path is correctly set as a Path object
    2. Default ignore patterns are applied when none are provided
    """
    # Initialize with default ignore patterns
    parser = CodeParser("test_repo")
    
    # Check repo_path is set correctly
    assert parser.repo_path == Path("test_repo")
    
    # Check default ignore patterns are set
    assert "*.git/*" in parser.ignore_patterns
    assert "*node_modules/*" in parser.ignore_patterns
    assert "*.png" in parser.ignore_patterns

def test_init_custom_ignore_patterns():
    """
    Test the initialization of CodeParser with custom ignore patterns.
    
    This test verifies that custom ignore patterns are correctly applied
    when provided, overriding the default patterns.
    """
    # Custom ignore patterns
    custom_patterns = ["*.log", "temp/*", "*.bak"]
    
    # Initialize with custom patterns
    parser = CodeParser("test_repo", ignore_patterns=custom_patterns)
    
    # Check repo_path is set correctly
    assert parser.repo_path == Path("test_repo")
    
    # Check custom patterns are used instead of defaults
    assert parser.ignore_patterns == custom_patterns
    assert "*.git/*" not in parser.ignore_patterns

def test_parse_repository():
    """
    Test the parse_repository method which processes all relevant files in a repository.
    
    This test creates a temporary directory structure with various files,
    runs the repository parsing, and verifies that all relevant files are
    correctly parsed with appropriate metadata.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory structure
        test_dir = "test_repo"
        os.makedirs(f"{test_dir}/src", exist_ok=True)
        
        # Create some test files with content
        with open(f"{test_dir}/src/main.py", "w") as f:
            f.write("def main():\n    print('Hello world')")
        with open(f"{test_dir}/src/utils.js", "w") as f:
            f.write("function helper() { return true; }")
        with open(f"{test_dir}/README.md", "w") as f:
            f.write("# Test Repository")
        
        # Create a file that should be ignored
        os.makedirs(f"{test_dir}/node_modules", exist_ok=True)
        with open(f"{test_dir}/node_modules/ignored.js", "w") as f:
            f.write("// This should be ignored")
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser.parse_repository()
            
            # Check the results
            assert len(result) == 3  # Should have 3 files (not the ignored one)
            
            # Normalize the paths for comparison
            normalized_paths = []
            for item in result:
                path = item['path'].replace('\\', '/')
                # Remove leading './' if present
                if path.startswith('./'):
                    path = path[2:]
                normalized_paths.append(path)
            
            # Verify file paths are correct
            expected_paths = ['src/main.py', 'src/utils.js', 'README.md']
            assert sorted(normalized_paths) == sorted(expected_paths)
            
            # Verify languages are detected correctly
            languages = {}
            for item in result:
                path = item['path'].replace('\\', '/')
                if path.startswith('./'):
                    path = path[2:]
                languages[path] = item['language']
                
            assert languages['src/main.py'] == 'python'
            assert languages['src/utils.js'] == 'javascript'
            assert languages['README.md'] == 'markdown'
            
            # Verify content is parsed correctly
            for item in result:
                path = item['path'].replace('\\', '/')
                if path.startswith('./'):
                    path = path[2:]
                    
                if path == 'src/main.py':
                    assert "def main():" in item['content']
                elif path == 'src/utils.js':
                    assert "function helper()" in item['content']
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)

def test_parse_file():
    """
    Test the parse_file method which processes a single file and extracts its content and metadata.
    
    This test creates a temporary file with known content, parses it using the CodeParser,
    and verifies that the returned metadata (path, content, language, size) is correct.
    """
    # Create a mock directory structure
    with pytest.MonkeyPatch().context() as mp:
        # Create a temporary test directory and file
        test_dir = "test_repo"
        os.makedirs(test_dir, exist_ok=True)
        
        # Create a test file with known content
        test_file_path = "test_file.py"
        test_content = "def test_function():\n    return True"
        
        with open(f"{test_dir}/{test_file_path}", "w") as f:
            f.write(test_content)
        
        try:
            # Initialize parser with our test directory
            parser = CodeParser(test_dir)
            
            # Call the method
            result = parser.parse_file(test_file_path)
            
            # Verify the result
            assert result is not None
            assert result['path'] == test_file_path
            assert result['content'] == test_content
            assert result['language'] == 'python'
            assert result['size'] == len(test_content)
            
            # Test with a non-existent file
            non_existent = parser.parse_file("non_existent.py")
            assert non_existent is None
        finally:
            # Clean up test directory
            import shutil
            shutil.rmtree(test_dir)





