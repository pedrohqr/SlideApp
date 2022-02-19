from flask import render_template, request, url_for, redirect

def init_app(app):
    @app.route('/')
    def hello():
        return 'ola mundo'