local M = {}

function M.detect_language(code)
  -- First try to get language from buffer filetype
  local filetype = vim.bo.filetype
  if filetype and filetype ~= '' then
    return M.normalize_language_name(filetype)
  end

  -- Fallback to code analysis
  return M.detect_from_code(code)
end

function M.normalize_language_name(lang)
  local lang_map = {
    ['c'] = 'c',
    ['cpp'] = 'cpp',
    ['c++'] = 'cpp',
    ['javascript'] = 'javascript',
    ['typescript'] = 'typescript',
    ['js'] = 'javascript',
    ['ts'] = 'typescript',
    ['lua'] = 'lua',
    ['python'] = 'python',
    ['py'] = 'python',
    ['java'] = 'java',
    ['rust'] = 'rust',
    ['rs'] = 'rust',
    ['go'] = 'go',
    ['php'] = 'php',
    ['ruby'] = 'ruby',
    ['rb'] = 'ruby',
    ['swift'] = 'swift',
    ['kotlin'] = 'kotlin',
    ['scala'] = 'scala',
    ['sh'] = 'bash',
    ['bash'] = 'bash',
    ['zsh'] = 'bash',
  }

  return lang_map[lang:lower()] or lang:lower()
end

function M.detect_from_code(code)
  if not code or code == '' then
    return 'unknown'
  end

  code = code:lower()

  -- C/C++ patterns
  if code:match '#include' or code:match 'void%s+' or code:match 'int%s+main' then
    if code:match 'std::' or code:match 'class%s+' or code:match 'namespace%s+' then
      return 'cpp'
    else
      return 'c'
    end
  end

  -- JavaScript/TypeScript patterns
  if code:match 'function%s+' or code:match 'const%s+' or code:match 'let%s+' or code:match 'var%s+' or code:match '=>' then
    if code:match 'interface%s+' or code:match 'type%s+' or code:match ':%s*%w+' then
      return 'typescript'
    else
      return 'javascript'
    end
  end

  -- Lua patterns
  if code:match 'function%s+' and (code:match 'local%s+' or code:match 'end%s*$' or code:match 'then%s+') then
    return 'lua'
  end

  -- Python patterns
  if code:match 'def%s+' or code:match 'import%s+' or code:match 'from%s+.+import' or code:match 'class%s+.+:' then
    return 'python'
  end

  -- Java patterns
  if code:match 'public%s+class' or code:match 'private%s+' or code:match 'public%s+static%s+void%s+main' then
    return 'java'
  end

  -- Rust patterns
  if code:match 'fn%s+' or code:match 'let%s+mut' or code:match 'impl%s+' or code:match 'struct%s+' then
    return 'rust'
  end

  -- Go patterns
  if code:match 'func%s+' or code:match 'package%s+' or code:match 'import%s*%(' then
    return 'go'
  end

  -- PHP patterns
  if code:match '<%?php' or code:match '%$%w+' or code:match 'function%s+%w+%(' then
    return 'php'
  end

  -- Ruby patterns
  if code:match 'def%s+' and (code:match 'end%s*$' or code:match '@%w+') then
    return 'ruby'
  end

  -- Shell script patterns
  if code:match '^#!/bin/bash' or code:match '^#!/bin/sh' or code:match 'echo%s+' or code:match '%$%w+' or code:match 'if%s*%[' then
    return 'bash'
  end

  -- Swift patterns
  if code:match 'func%s+' and (code:match 'var%s+' or code:match 'let%s+' or code:match 'import%s+UIKit') then
    return 'swift'
  end

  -- Kotlin patterns
  if code:match 'fun%s+' or code:match 'val%s+' or code:match 'var%s+' and code:match ':%s*%w+' then
    return 'kotlin'
  end

  -- Scala patterns
  if code:match 'def%s+' and (code:match 'val%s+' or code:match 'var%s+' or code:match 'object%s+') then
    return 'scala'
  end

  -- Default fallback
  return 'unknown'
end

function M.get_language_context(language)
  local contexts = {
    ['c'] = {
      common_headers = { 'stdio.h', 'stdlib.h', 'string.h', 'math.h', 'unistd.h' },
      common_patterns = { 'malloc', 'free', 'printf', 'scanf', 'struct', 'typedef' },
      memory_managed = false,
      compiled = true,
      paradigm = 'procedural',
      typical_extensions = { '.c', '.h' },
    },
    ['cpp'] = {
      common_headers = { 'iostream', 'vector', 'string', 'algorithm', 'memory' },
      common_patterns = { 'std::', 'class', 'namespace', 'template', 'new', 'delete' },
      memory_managed = false,
      compiled = true,
      paradigm = 'object-oriented',
      typical_extensions = { '.cpp', '.hpp', '.cc', '.cxx' },
    },
    ['javascript'] = {
      common_patterns = { 'function', 'const', 'let', 'var', '=>', 'async', 'await', 'require' },
      memory_managed = true,
      compiled = false,
      runtime = 'node/browser',
      paradigm = 'multi-paradigm',
      typical_extensions = { '.js', '.mjs' },
    },
    ['typescript'] = {
      common_patterns = { 'interface', 'type', 'function', 'const', '=>', 'async', 'export' },
      memory_managed = true,
      compiled = true,
      transpiled = true,
      paradigm = 'multi-paradigm',
      typical_extensions = { '.ts', '.tsx' },
    },
    ['lua'] = {
      common_patterns = { 'function', 'local', 'end', 'if', 'then', 'require', 'return' },
      memory_managed = true,
      compiled = false,
      interpreted = true,
      paradigm = 'multi-paradigm',
      typical_extensions = { '.lua' },
    },
    ['python'] = {
      common_patterns = { 'def', 'class', 'import', 'from', 'with', 'try', 'except' },
      memory_managed = true,
      compiled = false,
      interpreted = true,
      paradigm = 'multi-paradigm',
      typical_extensions = { '.py', '.pyw' },
    },
    ['java'] = {
      common_patterns = { 'public', 'private', 'class', 'interface', 'import', 'package' },
      memory_managed = true,
      compiled = true,
      runtime = 'jvm',
      paradigm = 'object-oriented',
      typical_extensions = { '.java' },
    },
    ['rust'] = {
      common_patterns = { 'fn', 'let', 'mut', 'impl', 'struct', 'enum', 'match' },
      memory_managed = false,
      compiled = true,
      paradigm = 'systems',
      typical_extensions = { '.rs' },
    },
    ['go'] = {
      common_patterns = { 'func', 'package', 'import', 'var', 'type', 'struct' },
      memory_managed = true,
      compiled = true,
      paradigm = 'procedural',
      typical_extensions = { '.go' },
    },
    ['php'] = {
      common_patterns = { 'function', 'class', 'public', 'private', 'require', 'include' },
      memory_managed = true,
      compiled = false,
      interpreted = true,
      paradigm = 'multi-paradigm',
      typical_extensions = { '.php', '.phtml' },
    },
    ['ruby'] = {
      common_patterns = { 'def', 'class', 'module', 'require', 'include', 'attr_' },
      memory_managed = true,
      compiled = false,
      interpreted = true,
      paradigm = 'object-oriented',
      typical_extensions = { '.rb', '.rbw' },
    },
    ['swift'] = {
      common_patterns = { 'func', 'var', 'let', 'class', 'struct', 'import' },
      memory_managed = true,
      compiled = true,
      paradigm = 'multi-paradigm',
      typical_extensions = { '.swift' },
    },
    ['kotlin'] = {
      common_patterns = { 'fun', 'val', 'var', 'class', 'object', 'import' },
      memory_managed = true,
      compiled = true,
      runtime = 'jvm',
      paradigm = 'multi-paradigm',
      typical_extensions = { '.kt', '.kts' },
    },
    ['scala'] = {
      common_patterns = { 'def', 'val', 'var', 'class', 'object', 'trait' },
      memory_managed = true,
      compiled = true,
      runtime = 'jvm',
      paradigm = 'functional',
      typical_extensions = { '.scala', '.sc' },
    },
    ['bash'] = {
      common_patterns = { 'echo', 'if', 'then', 'fi', 'for', 'while', 'function' },
      memory_managed = true,
      compiled = false,
      interpreted = true,
      paradigm = 'scripting',
      typical_extensions = { '.sh', '.bash' },
    },
  }

  return contexts[language]
    or {
      common_patterns = {},
      memory_managed = nil,
      compiled = nil,
      paradigm = 'unknown',
      typical_extensions = {},
    }
end

function M.get_analysis_hints(language, code)
  local context = M.get_language_context(language)
  local hints = {
    focus_areas = {},
    common_issues = {},
    best_practices = {},
  }

  -- Analyze the actual code for specific patterns
  code = code:lower()

  -- Language-specific analysis hints based on context and code content
  if language == 'c' or language == 'cpp' then
    table.insert(hints.focus_areas, 'Memory management (malloc/free or new/delete)')
    table.insert(hints.focus_areas, 'Pointer usage and dereferencing')
    table.insert(hints.focus_areas, 'Buffer overflow prevention')

    -- Check for specific patterns in the code
    if code:match 'malloc' or code:match 'calloc' then
      table.insert(hints.focus_areas, 'Dynamic memory allocation detected')
      table.insert(hints.common_issues, 'Memory leaks if free() not called')
    end

    if code:match '%*' then
      table.insert(hints.focus_areas, 'Pointer dereferencing operations')
      table.insert(hints.common_issues, 'Potential null pointer dereference')
    end

    if code:match 'strcpy' or code:match 'strcat' then
      table.insert(hints.common_issues, 'Buffer overflow risk with unsafe string functions')
      table.insert(hints.best_practices, 'Use strncpy/strncat for safer string operations')
    end

    table.insert(hints.best_practices, 'Always check malloc return values')
    table.insert(hints.best_practices, 'Free allocated memory')
  elseif language == 'javascript' or language == 'typescript' then
    table.insert(hints.focus_areas, 'Asynchronous operations')
    table.insert(hints.focus_areas, 'Callback handling')

    -- Check for async patterns
    if code:match 'async' or code:match 'await' then
      table.insert(hints.focus_areas, 'Async/await pattern usage')
      table.insert(hints.best_practices, 'Proper error handling with try/catch for async operations')
    end

    if code:match 'promise' or code:match '%.then' then
      table.insert(hints.focus_areas, 'Promise chain management')
      table.insert(hints.common_issues, 'Unhandled promise rejections')
    end

    if code:match 'callback' or code:match 'function%(' then
      table.insert(hints.common_issues, 'Potential callback hell')
    end

    if language == 'typescript' then
      table.insert(hints.focus_areas, 'Type checking and interfaces')
    end

    table.insert(hints.best_practices, 'Use async/await for promises')
    table.insert(hints.best_practices, 'Validate input parameters')
  elseif language == 'lua' then
    table.insert(hints.focus_areas, 'Table operations')
    table.insert(hints.focus_areas, 'Module system usage')

    -- Check for specific Lua patterns
    if code:match 'pairs' or code:match 'ipairs' then
      table.insert(hints.focus_areas, 'Table iteration patterns')
    end

    if code:match 'setmetatable' or code:match 'getmetatable' then
      table.insert(hints.focus_areas, 'Metatable behavior and metamethods')
    end

    if not code:match 'local%s+' and code:match 'function%s+%w+' then
      table.insert(hints.common_issues, 'Global function declaration detected')
      table.insert(hints.best_practices, 'Consider using local functions to avoid global namespace pollution')
    end

    if code:match 'require' then
      table.insert(hints.focus_areas, 'Module loading and dependencies')
    end

    table.insert(hints.common_issues, 'Nil value handling')
    table.insert(hints.best_practices, 'Use local variables when possible')
    table.insert(hints.best_practices, 'Proper error handling with pcall')
  elseif language == 'python' then
    table.insert(hints.focus_areas, 'Exception handling')
    table.insert(hints.focus_areas, 'Iterator and generator usage')

    if code:match 'try:' or code:match 'except' then
      table.insert(hints.focus_areas, 'Exception handling patterns')
    end

    if code:match 'yield' then
      table.insert(hints.focus_areas, 'Generator function behavior')
    end

    if code:match 'with%s+' then
      table.insert(hints.focus_areas, 'Context manager usage')
      table.insert(hints.best_practices, 'Proper resource management with context managers')
    end

    table.insert(hints.best_practices, 'Follow PEP 8 style guidelines')
    table.insert(hints.best_practices, 'Use descriptive variable names')
  end

  -- Add general hints based on context properties
  if not context.memory_managed then
    table.insert(hints.focus_areas, 'Manual memory management requirements')
  end

  if context.compiled then
    table.insert(hints.focus_areas, 'Compile-time optimizations and checks')
  end

  return hints
end

function M.should_use_examples(language)
  -- Determine if we have good examples for this language
  local supported_languages = {
    'c',
    'cpp',
    'javascript',
    'typescript',
    'lua',
    'python',
  }

  for _, lang in ipairs(supported_languages) do
    if language == lang then
      return true
    end
  end

  return false
end

function M.get_language_documentation_style(language)
  local styles = {
    ['c'] = {
      comment_style = '/* */',
      documentation_format = 'doxygen',
      header_convention = 'snake_case.h',
    },
    ['cpp'] = {
      comment_style = '// or /* */',
      documentation_format = 'doxygen',
      header_convention = 'PascalCase.hpp',
    },
    ['javascript'] = {
      comment_style = '// or /* */',
      documentation_format = 'jsdoc',
      module_convention = 'camelCase.js',
    },
    ['typescript'] = {
      comment_style = '// or /* */',
      documentation_format = 'tsdoc',
      module_convention = 'camelCase.ts',
    },
    ['lua'] = {
      comment_style = '--',
      documentation_format = 'ldoc',
      module_convention = 'snake_case.lua',
    },
    ['python'] = {
      comment_style = '#',
      documentation_format = 'sphinx/docstring',
      module_convention = 'snake_case.py',
    },
  }

  return styles[language] or {
    comment_style = '//',
    documentation_format = 'generic',
    module_convention = 'unknown',
  }
end

return M
