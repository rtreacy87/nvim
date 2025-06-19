# Detailed Breakdown of `handle_method_not_allowed` Function

## ASCII Diagram

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

## Executive Summary

The `handle_method_not_allowed` function is an HTTP error handler that constructs a standardized HTTP 405 "Method Not Allowed" response. This function is typically called when a web server receives an HTTP request using a method (GET, POST, PUT, DELETE, etc.) that is not supported for a particular resource or endpoint.

The function's primary purpose is to populate an `http_response_t` structure with all the necessary components of a proper HTTP 405 error response: setting the appropriate status code, creating an informative error message body, calculating the message length, and adding the correct Content-Type header. This ensures that clients receive a well-formed, standards-compliant HTTP error response that clearly communicates why their request was rejected.

This type of function is essential in web server implementations as it provides consistent error handling and helps maintain proper HTTP protocol compliance while giving developers a reusable way to handle unsupported HTTP methods.

### Required Header Files

To compile and use this function, you'll need to include the following standard C library headers:

- `#include <string.h>` - For `strdup()`, `strlen()`, and `strcpy()` functions
- `#include <stdlib.h>` - For memory allocation functions (required by `strdup()`)

Additionally, you'll need the custom header file that defines the `http_response_t` structure.

## Line-by-Line Breakdown

```c
void handle_method_not_allowed(http_response_t* response) {
```
**Function declaration**: This defines a function named `handle_method_not_allowed` that returns nothing (`void`) and accepts a single parameter - a pointer to an `http_response_t` structure named `response`. The pointer parameter allows the function to modify the original response structure rather than working with a copy, which is essential since the function's purpose is to populate this structure with response data.

```c
response->status_code = 405; // Method not allowed
```
**Status code assignment**: This line uses the arrow operator (`->`) to access the `status_code` member of the `http_response_t` structure that `response` points to, and assigns it the value 405. The HTTP status code 405 specifically means "Method Not Allowed" according to RFC specifications, indicating that the request method (GET, POST, etc.) is not supported by the target resource. This is the most critical piece of information that tells the client exactly what type of error occurred.

```c
response->body = strdup("Method not allowed");
```
**Response body creation**: This line assigns a dynamically allocated copy of the string "Method not allowed" to the `body` member of the response structure. The `strdup()` function (found in `<string.h>`) allocates memory on the heap, copies the string literal into that memory, and returns a pointer to the newly allocated string. This is important because it ensures the response body persists beyond the function's scope and can be safely used by the calling code. The caller will need to remember to free this memory later to prevent memory leaks.

```c
response->body_length = strlen(response->body);
```
**Body length calculation**: This line calculates the length of the response body string and stores it in the `body_length` member. The `strlen()` function (found in `<string.h>`) counts the number of characters in the string (excluding the null terminator). Setting the body length is crucial for HTTP responses because it allows the client to know exactly how many bytes of response data to expect, and it's often required for the Content-Length header in HTTP protocol compliance.

```c
strcpy(response->headers[0][0], "Content-Type");
```
**Header name assignment**: This line copies the string "Content-Type" into the first header's name field. The `headers` member appears to be a two-dimensional array where `headers[0][0]` represents the name of the first header. `strcpy()` (found in `<string.h>`) performs a string copy operation, duplicating "Content-Type" into the designated memory location. The Content-Type header is essential because it tells the client what kind of data format the response body contains.

```c
strcpy(response->headers[0][1], "text/plain");
```
**Header value assignment**: This line copies "text/plain" into the first header's value field at `headers[0][1]`. This sets the Content-Type header value to "text/plain", indicating that the response body contains plain text without any special formatting, markup, or encoding. This is appropriate for a simple error message since the body is just a straightforward text string. Like the previous line, this uses `strcpy()` from `<string.h>`.

```c
response->header_count = 1;
```
**Header count tracking**: This final line sets the `header_count` member to 1, indicating that the response contains exactly one HTTP header. This count is important for any code that processes the response, as it needs to know how many headers are present to iterate through them correctly when serializing the HTTP response or performing other header-related operations.

## Complete Function Code

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

## Memory Management Notes

- The function uses `strdup()` to allocate memory for the response body
- The caller is responsible for freeing the allocated memory to prevent memory leaks
- Consider using a cleanup function or ensuring proper memory management in the calling code

## HTTP Protocol Compliance

This function creates a response that complies with HTTP/1.1 standards:
- Uses the correct 405 status code for method not allowed errors
- Includes proper Content-Type header
- Provides a human-readable error message in the response body