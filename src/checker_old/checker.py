import json
import http.client
import time
from urllib.parse import urlparse

import boto3
import os
from datetime import datetime # for timestamp


    # Initialize the DynamoDB client 
dynamo_db = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("DYNAMODB_TABLE")
table = dynamo_db.Table(TABLE_NAME)

# This is the entry point for the Lambda function
# The event object will contain the input from Step Functions.
def handler(event, context):
   
    # print(f"Received event: {json.dumps(event)}")

    
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

    timestamp = datetime.utcnow().isoformat()

    try:
        # Establish connection
        conn = http.client.HTTPSConnection(hostname, timeout=10)

        # disguise as a real browser
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        
        start_time = time.time()
        conn.request("GET", path, headers=headers)
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

    # item for DynamoDB
    item = {
        "Url": url,
        "Timestamp": timestamp,
        "StatusCode": status_code,
        "Latency": latency_ms,
        # Redirects are considered successful
        "Success" : 200 <= status_code < 400,
        "is_redirect" : 300 <= status_code < 400,
        "Error": error
    }

    if error: 
        item["Error"] = error
            
    try:
        table.put_item(Item=item)
        print(f"Saved to DB: {item}")
    except Exception as e:
        print(f"DB Write Failed: {str(e)}")

    return item