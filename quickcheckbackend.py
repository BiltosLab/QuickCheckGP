import os
import time
import numpy as np
from flask import Flask, request, jsonify
import face_recognition

app = Flask(__name__)

# Global lists to store face encodings and corresponding IDs
known_faces = []
known_ids = []

# Function to load and encode known student faces
def load_known_faces_and_ids(directory):
    for name in os.listdir(directory):
        subdirectory = os.path.join(directory, name)
        if os.path.isdir(subdirectory):
            for filename in os.listdir(subdirectory):
                image_path = os.path.join(subdirectory, filename)
                image = face_recognition.load_image_file(image_path)
                face_encodings = face_recognition.face_encodings(image)
                if face_encodings:  # Check if a face is found
                    known_faces.append(face_encodings[0])
                    known_ids.append(name)
                    print(f"Loaded face for {name} from {filename}")
                else:
                    print("No face found in, Deleting",os.path.join(subdirectory, filename))
                    #os.remove(os.path.join(subdirectory, filename)) #Added deleting undetected faces for better performance
# Disable this if u want to test stuff

# Initial load of known faces and IDs from 'images/' directory
load_known_faces_and_ids('images/')

@app.route('/checkface', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file uploaded!', 400

    uploaded_file = request.files['file']
    if uploaded_file.filename == '':
        return 'No selected file', 400

    filename = f"temp_{int(time.time())}.jpg"
    uploaded_file.save(filename)

    unknown_image = face_recognition.load_image_file(filename)
    unknown_encodings = face_recognition.face_encodings(unknown_image)
    results = []
    if unknown_encodings:
        matches = face_recognition.compare_faces(known_faces, unknown_encodings[0])
        face_distances = face_recognition.face_distance(known_faces, unknown_encodings[0])
        best_match_index = np.argmin(face_distances)
        if matches[best_match_index]:
            student_id = known_ids[best_match_index]
            results.append(student_id)
    os.remove(filename)  # Clean up after checking
    return jsonify({"recognized_ids": results}), 200

@app.route('/addfacedata', methods=['POST'])
def add_face_data():
    student_id = request.form.get('student_id')
    file = request.files.get('file')

    if not student_id or not file:
        return "Missing student ID or file", 400

    # Create directory for the student if it doesn't exist
    student_path = os.path.join('images', student_id)
    if not os.path.exists(student_path):
        os.makedirs(student_path)

    # Save the file
    filename = f"{int(time.time())}.jpg"  # Ensure unique filename
    file_path = os.path.join(student_path, filename)
    file.save(file_path)
    # Load and encode the new face
    new_image = face_recognition.load_image_file(file_path)
    new_face_encodings = face_recognition.face_encodings(new_image)
    if new_face_encodings:
        known_faces.append(new_face_encodings[0])
        known_ids.append(student_id)
        return jsonify({"message": f"Image and face encoding saved successfully for student ID {student_id}"}), 200
    else:
        os.remove(file_path)
        print("No face detected in the uploaded image, Deleting ",file_path)
        return jsonify({"message": "No face detected in the uploaded image"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
