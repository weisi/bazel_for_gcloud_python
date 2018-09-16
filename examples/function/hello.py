from function import gcf_utils

@gcf_utils.plain_text_response
def hello(request):
  messages = list()
  messages.append('Hi there,')
  messages.append(f'You are visiting path "{request.path}".')
  messages.append(
    f'This function "{gcf_utils.current_function_name()}" '
    f'is running on GCP project {gcf_utils.current_gcloud_project()}.'
  )
  messages.append(f'Your IP address is {gcf_utils.remote_ip()}')
  return '\n'.join(messages)
