import boto3
from botocore.exceptions import ClientError
from datetime import datetime
profile_name = input("Enter AWS Profile Name (or press Enter for default): ").strip() or None
region = input("Enter AWS region (press Enter for us-east-1) ").strip() or "us-east-1" 
GREEN = '\033[92m'
RED = '\033[91m'
END = '\033[0m'
def find_old_access_keys():
    session= boto3.Session(profile_name=profile_name, region_name=region)
    iam = session.client('iam')
    print(f"Using profile: {profile_name if profile_name else 'default'}, region: {region}")
    # print (f"available operations: {iam.meta.service_model.operation_names}") 
    print("Fetching users...")
    users= iam.list_users()
    print(f"Found {len(users['Users'])} users.")
    # print(f"users: {users}")
    for user in users['Users']:
        print(f"\nuser: {user}")
        user_name= user['UserName']
        print(f"Checking access keys for user: {user_name}")
        access_keys= iam.list_access_keys(UserName=user_name)
        # print(f"\naccess_keys: {access_keys}")
        for key in access_keys['AccessKeyMetadata']:
            print(f"\nkey: {key}")
            access_key_id= key['AccessKeyId']
            create_date= key['CreateDate']
            age= (datetime.now(create_date.tzinfo) - create_date).days
            if age > 90:
                print(f"{RED}User: {user_name} has an old access key: {access_key_id}, created on {create_date}, age:{age}  days {END}")
            else:
                print(f"{GREEN}User: {user_name} has a recent access key: {access_key_id}, created on {create_date.tzinfo}, age: {age} days {END}")

find_old_access_keys()    
