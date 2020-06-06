#!/usr/bin/env python

import tweepy
import logging
from config import create_api
import json

root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',level=logging.INFO)


def lambda_handler(event, context):
    
    api = create_api()
    
    for record in event['Records']:
        print(record['body'])
        raw_record = record['body']
        print("raw_length: ", len(raw_record))
        tweet = (raw_record[:275] + '..') if len(raw_record) > 279 else raw_record
        print("tweet_length: ", len(tweet))
        logging.info("[INFO] Publishing the queued tweet: " + tweet)
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