import boto3
import json

def handler(event, context):
    print(f"Proxy event received {json.dumps(event)}")

# Destination address
    target_arn = event.get("target_arn")
    payload = event.get("payload")

    if not target_arn:
        raise ValueError("must provide target_arn")
        
    # which region the target is in
    # ARN format: arn:aws:lambda:region:account:function    
       
    target_region = target_arn.split(":")[3]

    # connect to that regoin
    target_client = boto3.client("lambda", region_name = target_region)

    # make the long distance call
    response = target_client.invoke(
        FunctionName = target_arn,
        InvocationType = "RequestResponse",
        Payload = json.dumps(payload)
    )

    # return the response
    response_payload = json.loads(response['Payload'].read())
    return response_payload