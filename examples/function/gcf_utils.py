from flask import request, Response
import http
import os


def plain_text_response(fn):
    def _wrapper(*args, **kwargs):
        return Response(fn(*args, **kwargs), mimetype='text/plain')

    _wrapper.__name__ = fn.__name__
    return _wrapper


def http_no_content(fn):
    def _wrapper(*args, **kwargs):
        fn(*args, **kwargs)
        return (str(), http.HTTPStatus.NO_CONTENT)

    _wrapper.__name__ = fn.__name__
    return _wrapper


def execution_id():
    return request.headers.get('Function-Execution-Id')


def remote_ip():
    return request.headers.get('X-Appengine-User-Ip')


def current_gcloud_project():
    return os.environ.get('GCP_PROJECT') \
        or os.environ.get('GCLOUD_PROJECT') \
        or os.environ.get('GOOGLE_CLOUD_PROJECT')


def current_function_name():
    return os.environ.get('FUNCTION_NAME')


def current_function_region():
    return os.environ.get('FUNCTION_REGION')
