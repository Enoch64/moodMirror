from flask import Flask, request
from flask_cors import CORS
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
CORS(app)

@app.route('/')
def handle_init():
    # Log the initial HTTP request
    return "HTTP Init received"

@app.route('/upload', methods=['POST'])
def upload_image():
    # get the data from the post request
    data = request.data
    print(data)
    # Acknowledge that the file has been received
    return "File uploaded successfully", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5729)