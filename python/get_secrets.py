
import boto3
from botocore.exceptions import ClientError


def get_secret():

    secret_name = input("Enter Secret Name (or press Enter for default): ").strip() or ""
    region_name = input("Enter Region Name (or press Enter for default): ").strip() or "REGION_NAME"
    profile_input = input("Enter AWS Profile Name (or press Enter for default): ").strip()
    profile_name = profile_input if profile_input else None
    
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
        if not secret_name:
            # List all secrets if secret_name is blank
            print("\nListing all secrets:")
            response = client.list_secrets()
            secrets = response.get('SecretList', [])
            if secrets:
                for secret in secrets:
                    print(f"  - {secret['Name']}")
            else:
                print("  No secrets found")
        else:
            # Get specific secret
            get_secret_value_response = client.get_secret_value(
                SecretId=secret_name
            )
            if 'SecretString' in get_secret_value_response:
                secret = get_secret_value_response['SecretString']
                print(secret)
            else:
                print("SecretString not found in the response")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        else:
            raise e
        
get_secret() 
