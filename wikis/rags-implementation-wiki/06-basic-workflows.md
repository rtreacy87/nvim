# 06 - Basic Workflows

## Daily RAGS Workflows

Now that your RAGS system is set up, let's explore how to use it effectively in your daily development workflow. This guide covers common patterns and practical examples.

## Getting Started

### Opening CodeCompanion

```bash
# In Neovim, use your configured keybinding
<leader>cc  # Opens CodeCompanion chat

# Or use the command
:CodeCompanionChat
```

### Basic Chat Interface

When CodeCompanion opens, you'll see:
- **Chat window** on the right side
- **Welcome message** with available slash commands
- **Input area** at the bottom for typing

## Core Slash Commands

### `/codebase` - Search Your Code

The most powerful command for understanding your codebase:

```
/codebase authentication middleware
/codebase how to handle user login
/codebase database connection setup
/codebase error handling patterns
```

**Example Conversation:**
```
You: /codebase how does user authentication work in this project?

AI: Based on your codebase, you're using a JWT-based authentication system. Here's how it works:

**File: auth/middleware.py** (similarity: 0.92)
```python
def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'error': 'No token provided'}), 401
        
        try:
            payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user = User.query.get(payload['user_id'])
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
            
        return f(current_user, *args, **kwargs)
    return decorated_function
```

The authentication flow is:
1. Client sends JWT token in Authorization header
2. Middleware validates token using SECRET_KEY
3. If valid, extracts user_id and loads User object
4. Passes current_user to the protected route

You can use this by decorating your routes with @require_auth.
```

### `/docs` - Search Documentation

Find relevant documentation and README files:

```
/docs API endpoints
/docs installation guide
/docs configuration options
/docs troubleshooting
```

### `/tests` - Find Test Examples

Discover how features are tested:

```
/tests user authentication
/tests database queries
/tests API endpoints
/tests error handling
```

## Common Workflow Patterns

### 1. Understanding New Code

When working with unfamiliar code:

```
# Step 1: Get overview
/codebase what does this project do

# Step 2: Understand specific files
/codebase how does [filename] work

# Step 3: Find related code
/codebase similar to [current function]
```

**Example:**
```
You: I'm looking at user_service.py. How does it work?

AI: /codebase how does user_service.py work

[AI provides detailed explanation with relevant code snippets]

You: How do I test these user service functions?

AI: /tests user service functions

[AI shows test examples and patterns]
```

### 2. Implementing New Features

When adding new functionality:

```
# Step 1: Find similar implementations
/codebase similar feature to what I want to build

# Step 2: Understand patterns
/codebase how are [similar features] implemented

# Step 3: Find test patterns
/tests how to test [similar functionality]
```

**Example:**
```
You: I need to add email notifications. How are notifications handled in this project?

AI: /codebase notification system

[Shows existing notification code]

You: How should I test email notifications?

AI: /tests email notifications

[Shows testing patterns for notifications]
```

### 3. Debugging Issues

When troubleshooting problems:

```
# Step 1: Find error handling patterns
/codebase error handling for [specific area]

# Step 2: Look for similar issues
/codebase [error message or symptom]

# Step 3: Find debugging examples
/tests debugging [specific functionality]
```

### 4. Code Review and Refactoring

When reviewing or improving code:

```
# Find better patterns
/codebase best practices for [specific area]

# Look for similar implementations
/codebase alternative approaches to [current method]

# Check test coverage
/tests coverage for [specific functionality]
```

## Context Sharing

### Buffer Context

Share your current file with the AI:

```
# Use the buffer variable
@buffer How can I improve this code?

# Or select specific lines and use
<leader>cc  # with visual selection
```

### Viewport Context

Share what's currently visible:

```
@viewport Explain this function

@viewport What's wrong with this code?
```

### Selection Context

Share specific code selections:

```
# Select code in visual mode, then
<leader>cc

# In chat:
@selection How can I optimize this?
```

## Keyboard Shortcuts

### Quick Actions

```bash
<leader>cq  # Quick codebase query
<leader>ce  # Explain current file
<leader>cd  # Search documentation
<leader>ct  # Search tests
```

### VectorCode Management

```bash
<leader>vr  # Register current buffer
<leader>vu  # Update index
<leader>vq  # Direct VectorCode query
```

## Effective Prompting Tips

### Be Specific

❌ **Poor:** `/codebase functions`
✅ **Good:** `/codebase user authentication functions`

❌ **Poor:** `/codebase database`
✅ **Good:** `/codebase database connection and query patterns`

### Use Context

❌ **Poor:** `How do I add validation?`
✅ **Good:** `@buffer How do I add validation to this form like other forms in the project?`

### Combine Commands

```
/codebase user registration process

Based on that code, how would I add email verification to the registration flow?

/tests user registration

How should I test the email verification feature?
```

### Ask Follow-up Questions

```
You: /codebase authentication middleware

AI: [Shows auth middleware code]

You: How do I add role-based permissions to this middleware?

AI: [Provides role-based auth solution]

You: Show me examples of how roles are used in the existing codebase

AI: /codebase role permissions examples
```

## Real-World Examples

### Example 1: Adding a New API Endpoint

```
You: I need to add a new API endpoint for user profiles. How are other endpoints structured?

AI: /codebase API endpoint patterns

[Shows existing endpoint structure]

You: @buffer How should I structure this new profile endpoint based on the existing patterns?

AI: Based on your codebase patterns, here's how you should structure the profile endpoint:

[Provides specific implementation following project conventions]

You: How are similar endpoints tested?

AI: /tests API endpoint testing

[Shows testing patterns and examples]
```

### Example 2: Debugging a Performance Issue

```
You: The user dashboard is loading slowly. How are other dashboards optimized?

AI: /codebase dashboard optimization performance

[Shows performance optimization patterns]

You: @viewport This is the slow code. What optimizations can I apply?

AI: Looking at your code and the optimization patterns in your codebase, here are specific improvements:

[Provides targeted optimization suggestions]
```

### Example 3: Understanding Legacy Code

```
You: I need to modify the payment processing system but don't understand how it works.

AI: /codebase payment processing system

[Explains payment flow with code examples]

You: How is payment processing tested?

AI: /tests payment processing

[Shows test examples and edge cases]

You: What happens when payments fail?

AI: /codebase payment error handling failure

[Shows error handling patterns]
```

## Productivity Tips

### 1. Index Your Projects Regularly

```bash
# Set up automatic indexing
crontab -e

# Add this line for weekly updates
0 2 * * 0 cd /path/to/project && vectorcode update
```

### 2. Use Multiple Projects

```bash
# Index different projects (each gets its own collection)
cd ~/projects/backend
vectorcode init && vectorcode vectorise .

cd ~/projects/frontend
vectorcode init && vectorcode vectorise .

cd ~/projects/docs
vectorcode init && vectorcode vectorise .

# VectorCode automatically manages separate collections per project
```

### 3. Create Custom Aliases

```bash
# Add to your shell config
alias rags-update="vectorcode update && echo 'RAGS index updated'"
alias rags-health="vectorcode check && curl -s http://127.0.0.1:11434/api/tags"
```

### 4. Use Templates for Common Queries

Create a note file with common query patterns:

```markdown
# RAGS Query Templates

## Understanding Code
- /codebase how does [component] work
- /codebase [component] architecture
- /codebase [component] dependencies

## Finding Examples
- /codebase examples of [pattern]
- /tests [functionality] testing
- /docs [feature] documentation

## Debugging
- /codebase [error message]
- /codebase error handling for [component]
- /tests debugging [issue]
```

## Troubleshooting Common Issues

### Slow Responses

```bash
# Check system resources
docker stats chromadb
ps aux | grep ollama

# Optimize model selection
# Use codellama:7b for simple queries
# Use codellama:13b for complex analysis
```

### No Results Found

```bash
# Update index
vectorcode update

# Check if files are indexed
vectorcode list-collections

# Verify file extensions in config
cat ~/.config/vectorcode/config.json | grep supported_extensions
```

### Context Too Large

```bash
# Limit results in queries
/codebase authentication --max-results 3

# Use more specific queries
# Instead of: /codebase functions
# Use: /codebase user authentication functions
```

## What's Next?

Now that you're comfortable with basic workflows, you can explore advanced features like custom slash commands, model optimization, and workflow automation.

In the next guide, we'll cover:
1. Creating custom slash commands
2. Advanced model selection strategies
3. Performance optimization techniques
4. Workflow automation and scripts

---

**Continue to:** [07 - Advanced Features](07-advanced-features.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for workflow-specific issues.
