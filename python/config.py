import tweepy
import logging
import os
import boto3
import base64
import json
from botocore.exceptions import ClientError

logger = logging.getLogger()

ENVIRONMENT = os.environ['Environment']
CONSUMER_K = "CONSUMER_KEY-" + ENVIRONMENT
CONSUMER_SEC = "CONSUMER_SECRET-" + ENVIRONMENT
ACCESS_TOK = "ACCESS_TOKEN-" + ENVIRONMENT
ACCESS_TOKEN_SEC = "ACCESS_TOKEN_SECRET-" + ENVIRONMENT

region_name = "eu-west-1"


def create_api():
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=CONSUMER_K
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
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
            SecretId=CONSUMER_SEC
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
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
            SecretId=ACCESS_TOK
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
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
            SecretId=ACCESS_TOKEN_SEC
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            access_token_secret_string = get_secret_value_response['SecretString']
            d = json.loads(access_token_secret_string)
            access_token_secret = d['ACCESS_TOKEN_SECRET']
        else:
            access_token_secret_string = base64.b64decode(get_secret_value_response['SecretBinary'])
            d = json.loads(access_token_secret_string)
            access_token_secret = d['ACCESS_TOKEN_SECRET']

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    api = tweepy.API(auth, wait_on_rate_limit=True,
                     wait_on_rate_limit_notify=True)

    try:
        api.verify_credentials()
    except Exception as e:
        logger.error("Error creating API", exc_info=True)
        raise e
    logger.info("API created")
    return api
