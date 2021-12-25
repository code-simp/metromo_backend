from os import X_OK
from flask import Flask, render_template
app = Flask(__name__)

posts = [
    {
        'author' : 'Author 1',
        'book' : 'idk lets say 1',
        'year' : '2021'
    },
    {
        'author' : 'Author 2',
        'book' : 'idk lets say 2',
        'year' : '2021'
    }
]

@app.route("/")
@app.route('/home')
def home():
    return render_template('home.html',posts=posts)

@app.route('/about')
def about():
    return render_template('about.html')

if __name__ =='__main__':
    app.run(debug=True, host = '0.0.0.0', port = 3000)