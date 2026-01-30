from flask import Flask, jsonify 
import os 
 
app = Flask(__name__) 
 
@app.route('/') 
def home(): 
   return jsonify({ 
       "status": "success", 
       "message": "Welcome to Kubernetes Deployment", 
       "environment": os.getenv('APP_ENV', 'development') 
   }) 
 
@app.route('/health') 
def health(): 
   return jsonify({"status": "healthy"}), 200 
 
if __name__ == '__main__': 
   app.run(host='0.0.0.0', port=5000, debug=False) 
