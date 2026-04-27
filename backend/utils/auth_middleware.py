import os
from functools import wraps
from flask import request, jsonify
import jwt

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Look for the token in the Headers
        if 'Authorization' in request.headers:
            # Check format: "Bearer <token>"
            parts = request.headers['Authorization'].split()
            if len(parts) == 2 and parts[0] == 'Bearer':
                token = parts[1]

        if not token:
            return jsonify({'error': 'Token is missing or improperly formatted!'}), 401

        try:
            # Decode JWT
            jwt_secret = os.getenv("JWT_SECRET", "default_secret")
            data = jwt.decode(token, jwt_secret, algorithms=["HS256"])
            current_user = data['username']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token!'}), 401
            
        return f(current_user, *args, **kwargs)
        
    return decorated
