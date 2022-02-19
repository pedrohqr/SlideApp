import views
from flask import Flask
import conn_db

def create_app():
    #main factory of the web server
    app = Flask(__name__)
    conn_db.DBConnect()
    views.init_app(app)
    return app
    
if __name__ =='__main__':
    app = create_app()
    app.run('0.0.0.0', 4449)