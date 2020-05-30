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
        raw_record = record['body']
        tweet = (raw_record[:278] + '..') if len(raw_record) > 279 else raw_record
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