from flask import Flask, request

from app_engine import gae_utils

app = Flask(__name__)

@app.route('/')
@gae_utils.plain_text_response
def homepage():
  messages = list()
  messages.append('Hi there,')
  messages.append(f'You are visiting path "{request.path}".')
  messages.append(
    f'This app "{gae_utils.current_application_name()}" '
    f'is running on GCP project {gae_utils.current_gcloud_project()}.'
  )
  messages.append(f'Your IP address is {gae_utils.remote_ip()}')
  messages.append('Visit any other path to see a static file.')
  return '\n'.join(messages)
