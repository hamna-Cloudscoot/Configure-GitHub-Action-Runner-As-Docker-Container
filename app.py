# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def health_check():
    return 'Runner is up and running', 200
