from flask import Flask
from flask_mysqldb import MySQL

mysql =MySQL()

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')
    mysql.init_app(app)
    
    from .routes import main_bp
    app.register_blueprint(main_bp)
    
    return app