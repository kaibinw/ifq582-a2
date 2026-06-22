from flask import Flask, render_template
from flask_mysqldb import MySQL

mysql =MySQL()

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')
    mysql.init_app(app)
    
    from .routes import main_bp
    app.register_blueprint(main_bp)

    @app.errorhandler(404)
    def page_not_found(e):
        return render_template('error.html', code=404, message='Page not found'), 404
    
    @app.errorhandler(500)
    def internal_error(e):
        return render_template('error.html', code=500, message='Internal Server Error'), 500
    
    return app