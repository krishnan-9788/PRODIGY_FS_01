import os
from pymongo import MongoClient

# Establish connection to MongoDB using the URI from environment variables
def get_db():
    mongo_uri = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
    client = MongoClient(mongo_uri)
    # Return the 'auth_db' database
    return client["auth_db"]

db = get_db()
