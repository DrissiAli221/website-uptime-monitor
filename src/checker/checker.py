import json
import http.client
import time
from urllib.parse import urlparse

# This is the entry point for the Lambda function
# The event object will contain the input from Step Functions.
def handler(event, context):
    """
    Checks the status of a given URL.

    Args:
        event (dict): The input event, expected to contain a 'url' key.
        context (object): The Lambda context object (not used here).

    Returns:
        dict: A dictionary with the check results.
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Get the URL from the input event
    url = event.get("url") # Better than event['url'] to avoid KeyError
    if not url:
        raise ValueError("URL is required in the event payload")

    # Get the hostname and path
    parsed_url = urlparse(url) 
    hostname = parsed_url.netloc
    path = parsed_url.path or "/"

    status_code = 0
    latency_ms = -1
    error = None

    try:
        # Establish connection
        conn = http.client.HTTPSConnection(hostname, timeout=10)
        
        start_time = time.time()
        conn.request("GET", path)
        response = conn.getresponse()
        end_time = time.time()

        status_code = response.status
        latency_ms = round((end_time - start_time) * 1000)

        print(f"Checked {url}: Status Code={status_code}, Latency={latency_ms}ms")

    except Exception as e:
        error = str(e)
        print(f"Error checking {url}: {error}")
    
    finally:
        if 'conn' in locals():
            conn.close()

    return {
        "url": url,
        "statusCode": status_code,
        "latencyMilliseconds": latency_ms,
        "success": 200 <= status_code < 300,
        "error": error
    }