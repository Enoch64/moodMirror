from flask import Flask, request
from flask_socketio import SocketIO, send
from flask_cors import CORS
import eventlet

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'

# Use Flask-SocketIO to handle WebSocket connections
socketio = SocketIO(app, cors_allowed_origins="*")  # Allow all origins for CORS
CORS(app)

# Before request handler to log details of the incoming HTTP request
@app.before_request
def log_request():
    try:
        print(f"Received request: {request.method} {request.url}")
        print("Request Headers:")
        for header, value in request.headers:
            print(f"{header}: {value}")

        if request.method in ['POST', 'PUT', 'PATCH']:
            if request.is_json:
                print("Request Body (JSON):", request.get_json())
            elif request.form:
                print("Request Body (Form Data):", request.form)
            elif request.data:
                print("Request Body (Raw Data):", request.data.decode('utf-8'))
            else:
                print("Request Body is empty or unsupported format")
    except Exception as e:
        print(f"Error logging request: {e}")

# WebSocket connection handler
@socketio.on('connect')
def connect():
    print('Client successfully connected!')
    send("Connection established")

# Handle messages received on WebSocket
@socketio.on('message')
def handle_message(message):
    print('Received message: ', message)
    send({'data': 'Frame received'})

# Handle WebSocket disconnection
@socketio.on('disconnect')
def disconnect():
    print('Client disconnected')

# Start the Flask app with WebSocket support
if __name__ == '__main__':
   eventlet.wsgi.server(eventlet.listen(('0.0.0.0', 5729)), app)
