from flask import Flask, request, jsonify
import csv
import os

app = Flask(__name__, static_folder='.', static_url_path='')

@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    message = data.get('message')

    file_exists = os.path.isfile('submissions.csv')
    with open('submissions.csv', 'a', newline='') as csvfile:
        writer = csv.writer(csvfile)
        if not file_exists:
            writer.writerow(['Timestamp', 'Name', 'Email', 'Message'])
        writer.writerow([name, email, message])


    return jsonify({'message': 'Form submitted successfully!'})

@app.route('/')
def index():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    app.run(debug=True, port=5000)
