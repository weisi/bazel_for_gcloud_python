# Helper methods for using Python 3 on Google App Engine.
# Don't use gcf_utils directly if running on GAE, since some details are different.

from flask import request, Response
import http
import os

from function.gcf_utils import \
    plain_text_response, \
    http_no_content, \
    current_gcloud_project, \
    remote_ip


def current_application_name():
    # In the form of 's~xcode-dev'.
    return os.environ.get('GAE_APPLICATION')


def current_service_name():
    return os.environ.get('GAE_SERVICE')


def current_version():
    return os.environ.get('GAE_VERSION')


def current_instance():
    # It's the GAE instance ID, a.k.a. "clone_id".
    return os.environ.get('GAE_INSTANCE')
