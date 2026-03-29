from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Cart Service Running"

@app.route("/cart")
def cart():
    return "Cart Service Running"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)