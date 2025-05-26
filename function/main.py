import functions_framework
import logging

# Configure logging once, outside the function
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def hello_world(request):
    logger.info(f"Request method: {request.method}")
    logger.info(f"Request path: {request.path}")
    logger.info(f"Remote address: {request.remote_addr}")

    if request.method == "GET":
        return "Hello World!"
    else:
        return ("Method not allowed", 405)
