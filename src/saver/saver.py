import boto3
import os
import time

# this function is the only thing that talks to the db 
dynamodb = boto3.resource('dynamodb')
sns_client = boto3.client('sns') 

TABLE_NAME = os.environ.get('DYNAMODB_TABLE')
TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    # Event is the array from Step Functions: [US_Result, EU_Result]
    results = event
    
    if not results or len(results) == 0:
        return {"Status": "No results to save"}

    failed_regions = []

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

        if data['Success'] == False:
            failed_regions.append(f"{region_name} (Status : {data['StatusCode']})")  # single quotes!
        
        master_record[region_name] = {
            'Latency': data['Latency'],
            'StatusCode': data['StatusCode'],
            'Success': data['Success']
        }

    # save
    try:
        table.put_item(Item=master_record)
        print("Saved master record:", master_record)
        # return master_record Remove this !!!!
    except Exception as e:
        print(f"Error saving: {e}")
        raise e

    # print("DEBUG: Checking logic...", failed_regions) 

    # SNS Alert
    if len(failed_regions) > 0:
        # Global outage ?
        if len(failed_regions) == len(results):
            subject = "CRITICAL: Website Down Globally"
            severity = "CRITICAL"
        else:
            subject = "WARNING: Website Down in Some Regions"
            severity = "PARTIAL OUTAGE"

        print(f"{severity}: Sending Alert.")

        message = (
            f"{subject}\n"
            f"URL: {master_record['Url']}\n"
            f"Details:\n" + "\n".join(failed_regions)
        )

        sns_client.publish(
            TopicArn=TOPIC_ARN,
            Subject="URGENT: Website down",
            Message=message
        )
        print("Alert sent successfully.")

    return master_record


