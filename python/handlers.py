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
    
    twitter_client = create_api()
    
    for record in event['Records']:
        logging.info("Record Body: " + record['body'])
        raw_record = record['body']
        logging.info("raw_length: " + str(len(raw_record)))
        tweet = (raw_record[:275] + '..') if len(raw_record) > 279 else raw_record
        logging.info("tweet_length: " + str(len(tweet)))
        
        try:
            logging.info("Tweeting: %s", tweet)
            twitter_client.create_tweet(text=tweet)
        except tweepy.errors.TweepyException as e:
            logging.error("Tweepy error: %s", e)
            raise

    
    body = {
        "message": "ACK",
        "event": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }
    
    return response