"""
Cloud Function: Hello World
--------------------------
A simple HTTP-triggered Cloud Function that:
1. Accepts GET requests and returns "Hello World!"
2. Rejects all other HTTP methods with a 405 status code
3. Logs request details for monitoring and debugging
"""

import functions_framework
import logging

# Configure logging once, outside the function
# This ensures consistent logging across all function invocations
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def hello_world(request):
    """
    Main function handler for HTTP requests.
    
    Args:
        request: The HTTP request object containing method, path, and client info
        
    Returns:
        - For GET requests: "Hello World!" with 200 status code
        - For other methods: "Method not allowed" with 405 status code
    """
    # Log request details for monitoring and debugging
    logger.info(f"Request method: {request.method}")
    logger.info(f"Request path: {request.path}")
    logger.info(f"Remote address: {request.remote_addr}")

    # Handle different HTTP methods
    if request.method == "GET":
        return "Hello World!"
    else:
        return ("Method not allowed", 405)
