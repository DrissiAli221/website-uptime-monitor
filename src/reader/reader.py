import boto3
import os 
import json
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("DYNAMODB_TABLE")

table = dynamodb.Table(TABLE_NAME)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj) # Convert Decimal to float
        return super(DecimalEncoder, self).default(obj)


def handler(event, context):
    try:
        # scan the table (fine for <1mb)
        response = table.scan(Limit = 20)
        items = response.get("Items", [])

        # sort by timestamp
        items.sort(key = lambda x: x['Timestamp'], reverse = True)
        
        return {
            "statusCode" : 200,
            "headers" : {
                "Content-Type": "application/json",
                # for front-end
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET"
            },
            "body" : json.dumps(items, cls = DecimalEncoder)
        }
    except Exception as e:
        print(f"Error: {e}") #for cloudwatch
        return {
            "statusCode" : 500,
            "body" : json.dumps(str(e))
        }
