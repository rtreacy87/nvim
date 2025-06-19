local M = {}

local c_examples = [[
Here are examples of the expected analysis format:

## Example 1: HTTP Error Handler

```c
void handle_method_not_allowed(http_response_t* response) {
    response->status_code = 405; // Method not allowed
    response->body = strdup("Method not allowed");
    response->body_length = strlen(response->body);
    strcpy(response->headers[0][0], "Content-Type");
    strcpy(response->headers[0][1], "text/plain");
    response->header_count = 1;
}
```

### ASCII Diagram
```
INPUT:
┌─────────────────────────────────┐
│        http_response_t*         │
│           response              │
│                                 │
│  ┌─────────────────────────────┐│
│  │ status_code: <uninitialized>││
│  │ body: <uninitialized>       ││
│  │ body_length: <uninitialized>││
│  │ headers: <uninitialized>    ││
│  │ header_count: <uninit...>   ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
                │
                ▼
    ┌─────────────────────────────┐
    │   handle_method_not_allowed │
    │         function            │
    └─────────────────────────────┘
                │
                ▼
OUTPUT:
┌─────────────────────────────────┐
│        http_response_t*         │
│           response              │
│                                 │
│  ┌─────────────────────────────┐│
│  │ status_code: 405            ││
│  │ body: "Method not allowed"  ││
│  │ body_length: 17             ││
│  │ headers[0][0]: "Content-Type"││
│  │ headers[0][1]: "text/plain" ││
│  │ header_count: 1             ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

## Example 2: Route Registration

```c
void register_route(const char* path, void (*handler)(http_request_t*, http_response_t*)) {
    if (route_count < MAX_ROUTES) {
        routes[route_count].path = path;
        routes[route_count].handler = handler;
        route_count++;
    }
}
```

### ASCII Diagram
```
INPUT:
┌─────────────────────────────────┐
│         const char*             │
│           path                  │
│    "example: /api/users"        │
└─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│    void (*handler)(...)         │
│    function pointer             │
│  "example: &handle_users"       │
└─────────────────────────────────┘
                │
                ▼
    ┌─────────────────────────────┐
    │      register_route         │
    │        function             │
    └─────────────────────────────┘
                │
                ▼
OUTPUT (Global State Change):
┌─────────────────────────────────┐
│      routes[MAX_ROUTES]         │
│                                 │
│  Before:                        │
│  routes[0]: {empty}             │
│  routes[1]: {empty}             │
│  ...                            │
│  route_count: 0                 │
│                                 │
│  After:                         │
│  routes[0]: {path, handler}     │
│  routes[1]: {empty}             │
│  ...                            │
│  route_count: 1                 │
└─────────────────────────────────┘
```

Follow this format for your analysis.
]]

local lua_examples = [[
Here are examples for Lua function analysis (adapt the format as needed):

## Example: Lua Validation Function

```lua
function validate_user_input(username, email, password, age, phone)
    if not is_username_present(username) then
        return false, "Username is required"
    end
    
    if not is_username_valid_length(username) then
        return false, "Username must be between 3 and 20 characters"
    end
    
    return true, "Validation successful"
end
```

### ASCII Diagram
```
INPUT:
┌─────────────────────────────────┐
│     username (string)           │
│     email (string)              │
│     password (string)           │
│     age (number)                │
│     phone (string/optional)     │
└─────────────────────────────────┘
                │
                ▼
    ┌─────────────────────────────┐
    │    validate_user_input      │
    │        function             │
    └─────────────────────────────┘
                │
                ▼
OUTPUT:
┌─────────────────────────────────┐
│    boolean success              │
│    string error_message         │
│                                 │
│  Success: true, "Validation     │
│           successful"           │
│  Failure: false, "Username      │
│           is required"          │
└─────────────────────────────────┘
```

Follow this format for Lua analysis.
]]

local javascript_examples = [[
Here are examples for JavaScript function analysis:

## Example: JavaScript Async Function

```javascript
async function fetchUserData(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const userData = await response.json();
        return { success: true, data: userData };
    } catch (error) {
        return { success: false, error: error.message };
    }
}
```

### ASCII Diagram
```
INPUT:
┌─────────────────────────────────┐
│        userId (string)          │
│     "example: 'user123'"        │
└─────────────────────────────────┘
                │
                ▼
    ┌─────────────────────────────┐
    │      fetchUserData          │
    │    (async function)         │
    └─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│         Promise<Object>         │
│                                 │
│  Success: {                     │
│    success: true,               │
│    data: userData               │
│  }                              │
│                                 │
│  Failure: {                     │
│    success: false,              │
│    error: "error message"       │
│  }                              │
└─────────────────────────────────┘
```
]]

function M.get_examples_for_language(language)
  language = language:lower()

  if language == 'c' or language == 'cpp' or language == 'c++' then
    return c_examples
  elseif language == 'lua' then
    return lua_examples
  elseif language == 'javascript' or language == 'typescript' or language == 'js' or language == 'ts' then
    return javascript_examples
  else
    -- Default to C examples as a fallback
    return c_examples
  end
end

return M
