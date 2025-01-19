import io
from PIL import Image
import cv2 
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image

face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
model_best = load_model('face_model.h5') # set your machine model file path here
class_names = ['Angry', 'Disgusted', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']


def process_image(image_data):
    with Image.open(image_data) as img:
        gray = np.array(img.convert('L'))
        
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5, minSize=(30, 30))

        if len(faces) == 0:
            return "No face detected"

        x, y, w, h = faces[0]

        #Extract face region
        face_roi = gray[y:y + h, x:x + w]

        # Resize the face image to the required input size for the model
        face_image = cv2.resize(face_roi, (48, 48))
        # face_image = cv2.cvtColor(face_image, cv2.COLOR_BGR2GRAY)
        face_image = image.img_to_array(face_image)
        face_image = np.expand_dims(face_image, axis=0)
        face_image = np.vstack([face_image])

        # Predict emotion using the loaded model
        predictions = model_best.predict(face_image)
        emotion_label = class_names[np.argmax(predictions)]

        return emotion_label



# def handle_client(clientSocket):
#     image_data = io.BytesIO()
#     while True:
#         data = clientSocket.recv(1024)
#         if not data:
#             break
#         image_data.write(data)
#     image_data.seek(0)
#     emotion = process_image(image_data)
#     print(emotion)


# while True:
#     clientSocket, clientAddress = serverSocket.accept()
#     handle_client(clientSocket)