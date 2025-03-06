
import boto3
from botocore.exceptions import ClientError


def get_secret():

    secret_name = "SECRET_NAME"
    region_name = "REGION_NAME"
    profile_name = "PROFILE_NAME LEAVE IT BLANK IF YOU ARE USING DEFAULT PROFILE"
    # Create a Secrets Manager client
    session = boto3.Session(profile_name=profile_name)
    try:
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name
        )
        print("Session created")
    except Exception as e:
        print("Error creating session   ", e)
        return None

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        else:
            raise e

    if 'SecretString' in get_secret_value_response:
        secret = get_secret_value_response['SecretString']
        print(secret)
    else:
        print("SecretString not found in the response")
        
get_secret() 
