from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def create_app():
    # Initialize app
    app = Flask(__name__)
    
    # Enable CORS for all domains on all routes
    CORS(app)

    # Register Blueprints
    from routes.auth_routes import auth_bp
    from routes.protected_routes import protected_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(protected_bp, url_prefix='/api/protected')

    @app.route('/', methods=['GET'])
    def index():
        return {"message": "Welcome to the Secure Authentication API"}

    return app

if __name__ == '__main__':
    app = create_app()
    # Run server, debug mode on
    app.run(host='0.0.0.0', port=5000, debug=True)
