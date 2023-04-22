import tweepy
import logging
import os
import boto3
import base64
import json
from botocore.exceptions import ClientError

# Logging configuration
root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',level=logging.INFO)

secret_name = os.environ["SecretName"]
region_name = os.environ["AWSRegion"]

def create_api():
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
            raise e
    else:
        if 'SecretString' in get_secret_value_response:
            consumer_key_string = get_secret_value_response['SecretString']
            d = json.loads(consumer_key_string)
            consumer_key = d['CONSUMER_KEY']
        else:
            consumer_key_string = base64.b64decode(get_secret_value_response['SecretBinary'])
            d = json.loads(consumer_key_string)
            consumer_key = d['CONSUMER_KEY']

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
            raise e
    else:
        if 'SecretString' in get_secret_value_response:
            consumer_secret_string = get_secret_value_response['SecretString']
            d = json.loads(consumer_secret_string)
            consumer_secret = d['CONSUMER_SECRET']
        else:
            consumer_secret_string = base64.b64decode(get_secret_value_response['SecretBinary'])
            d = json.loads(consumer_secret_string)
            consumer_secret = d['CONSUMER_SECRET']
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
            raise e
    else:
        if 'SecretString' in get_secret_value_response:
            access_token_string = get_secret_value_response['SecretString']
            d = json.loads(access_token_string)
            access_token = d['ACCESS_TOKEN']
        else:
            access_token_string = base64.b64decode(get_secret_value_response['SecretBinary'])
            d = json.loads(access_token_string)
            access_token = d['ACCESS_TOKEN']

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
            raise e
    else:
        if 'SecretString' in get_secret_value_response:
            access_token_secret_string = get_secret_value_response['SecretString']
            d = json.loads(access_token_secret_string)
            access_token_secret = d['ACCESS_TOKEN_SECRET']
        else:
            access_token_secret_string = base64.b64decode(get_secret_value_response['SecretBinary'])
            d = json.loads(access_token_secret_string)
            access_token_secret = d['ACCESS_TOKEN_SECRET']

    twitter_client = tweepy.Client(consumer_key=consumer_key,
                       consumer_secret=consumer_secret,
                       access_token=access_token,
                       access_token_secret=access_token_secret)
    
    
    return twitter_client
