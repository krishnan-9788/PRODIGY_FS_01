from flask import Blueprint, jsonify
from utils.auth_middleware import token_required

protected_bp = Blueprint('protected', __name__)

# A protected route that requires a valid JWT
@protected_bp.route('/dashboard', methods=['GET'])
@token_required
def dashboard(current_user):
    # This route will only execute if token_required passes successfully
    return jsonify({
        "message": "Welcome to the secure dashboard!",
        "user_data": {
            "username": current_user
        }
    }), 200
