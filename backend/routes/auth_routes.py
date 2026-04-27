import os
from flask import Blueprint, request, jsonify
import bcrypt
import jwt
import datetime
from database import db

auth_bp = Blueprint('auth', __name__)

# Registration endpoint
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({"error": "Missing username or password"}), 400

    username = data['username']
    password = data['password']

    # Check for existing user
    existing_user = db.users.find_one({"username": username})
    if existing_user:
        return jsonify({"error": "User already exists"}), 409

    # Hash the password with bcrypt
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # Insert the new user into MongoDB
    user_doc = {
        "username": username,
        "password": hashed_password
    }
    db.users.insert_one(user_doc)

    return jsonify({"message": "User registered successfully"}), 201


# Login endpoint
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({"error": "Missing username or password"}), 400

    username = data['username']
    password = data['password']

    # Find the user in MongoDB
    user = db.users.find_one({"username": username})
    if not user:
        return jsonify({"error": "Invalid username or password"}), 401

    # Verify the password
    if bcrypt.checkpw(password.encode('utf-8'), user['password']):
        # Create JWT Token
        payload = {
            "username": username,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=24) # Token expires in 24 hours
        }
        
        jwt_secret = os.getenv("JWT_SECRET", "default_secret")
        token = jwt.encode(payload, jwt_secret, algorithm="HS256")
        
        # Return success with token
        return jsonify({
            "message": "Login successful",
            "token": token
        }), 200
    else:
        return jsonify({"error": "Invalid username or password"}), 401
