from flask import Flask
app = Flask(__name__)
@app.get("/get_test")
def get_test():
 return {"msg": "GET Success"}, 200
app.run(host="0.0.0.0", port=8986, debug=True)