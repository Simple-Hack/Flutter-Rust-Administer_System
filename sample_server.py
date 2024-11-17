from flask import Flask, send_from_directory, send_file
from flask_cors import CORS
import mimetypes

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 确保正确的MIME类型
mimetypes.init()
mimetypes.types_map['.js'] = 'application/javascript'

@app.route('/')
def serve_index():
    response = send_from_directory('build/web', 'index.html')
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Cross-Origin-Opener-Policy', 'same-origin')
    response.headers.add('Cross-Origin-Embedder-Policy', 'require-corp')
    return response

@app.route('/<path:path>')
def static_proxy(path):
    # 尝试根据路径发送文件
    try:
        # 根据文件扩展名获取MIME类型
        mime_type, _ = mimetypes.guess_type(path)
        response = send_file('build/web/' + path, mimetype=mime_type)
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Cross-Origin-Opener-Policy', 'same-origin')
        response.headers.add('Cross-Origin-Embedder-Policy', 'require-corp')
        return response
    except FileNotFoundError:
        # 如果文件未找到，则返回404错误
        return "File not found", 404

if __name__ == '__main__':
    app.run(host='localhost', port=8081)