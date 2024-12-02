from flask import Flask, request, render_template, redirect, url_for, flash
import psycopg2
from psycopg2.extras import RealDictCursor
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = 'your_secret_key'

conn = psycopg2.connect(
    dbname="myapp", user="myappuser", password="securepassword", host="localhost"
)

@app.route('/')
def home():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']

    with conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute('SELECT * FROM users WHERE username = %s', (username,))
        user = cursor.fetchone()

        if user and check_password_hash(user['password_hash'], password):
            return "Login successful!"
        else:
            flash("Invalid credentials.")
            return redirect(url_for('home'))

@app.route('/register', methods=['POST'])
def register():
    username = request.form['username']
    password = request.form['password']

    password_hash = generate_password_hash(password)

    with conn.cursor() as cursor:
        try:
            cursor.execute('INSERT INTO users (username, password_hash) VALUES (%s, %s)', (username, password_hash))
            conn.commit()
            flash("Registration successful! Please login.")
        except Exception as e:
            conn.rollback()
            flash(f"Error: {e}")
        return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)