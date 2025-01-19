from flask import Flask, request
from flask_cors import CORS
from model import process_image
import os,io
from PIL import Image

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
    image_data = io.BytesIO()
    image_data.write(data)
    image_data.seek(0)
    
    # Rotate the image by 90 degrees clockwise
    image = Image.open(image_data)
    rotated_image = image.rotate(-90, expand=True)
    rotated_image_data = io.BytesIO()
    rotated_image.save(rotated_image_data, format=image.format)
    rotated_image_data.seek(0)
    
    # Save the first incoming image during the server's uptime
    if not os.path.exists('first_image.jpg'):
        with open('first_image.jpg', 'wb') as f:
            f.write(rotated_image_data.getvalue())
    
    emotion_res = process_image(rotated_image_data)
    
    return emotion_res

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5729)