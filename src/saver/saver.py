import boto3
import os
import time

# this function is the only thing that talks to the db 
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    # Event is the array from Step Functions: [US_Result, EU_Result]
    results = event
    
    if not results or len(results) == 0:
        return {"Status": "No results to save"}

    first_result_data = results[0]['Payload']
    # master record
    master_record = {
        'Url': first_result_data['Url'],
        'Timestamp': first_result_data['Timestamp'],
    }
    # loop through region       
    for result in results:
        data = result['Payload']
        
        region_name = data.get('Region', 'unknown-region')
        
        master_record[region_name] = {
            'Latency': data['Latency'],
            'StatusCode': data['StatusCode'],
            'Success': data['Success']
        }

    # save
    try:
        table.put_item(Item=master_record)
        print("Saved master record:", master_record)
        return master_record
    except Exception as e:
        print(f"Error saving: {e}")
        raise e