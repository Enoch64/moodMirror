from flask import Flask, request
from flask_socketio import SocketIO, send
from flask_cors import CORS

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*")  # Allow all origins for CORS
CORS(app)

@app.route('/')
def handle_http_handshake():
    # Log the initial HTTP handshake
    print("HTTP handshake received")
    return "WebSocket handshake, initial HTTP request received"

@app.before_request
def log_request():
    print(f"Received request: {request.method} {request.url}")

@socketio.on('connect')
def connect():
    print('Client successfully connected!')
    send("Connection established")

@socketio.on('message')
def handle_message(message):
    print('Received message: ', message)
    send({'data': 'Frame received'})

@socketio.on('disconnect')
def disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5729)