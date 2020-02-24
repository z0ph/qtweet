#!/usr/bin/env python

import tweepy
import logging
from config import create_api
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def lambda_handler(event, context):
    
    api = create_api()
    
    for record in event['Records']:
        print(record['body'])
        tweet = record['body']
        logger.info("[INFO] Publishing the queued tweet: " + tweet)
        api.update_status(tweet)

    
    body = {
        "message": "ACK",
        "event": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }
    return response