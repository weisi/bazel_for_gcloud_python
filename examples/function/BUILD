load("@bazel_for_gcloud_python//infra/serverless:gcf_rules.bzl", "py_cloud_function")

py_library(
    name = "gcf_utils",
    srcs = [
        "gcf_utils.py",
    ],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "hello",
    srcs = [
        "hello.py",
    ],
    deps = [
        ":gcf_utils",
    ]
)

# 'bazel run' this rule to trigger deployment.
py_cloud_function(
    # Required parameters:
    name = "hello_deploy",
    src = ":hello",
    entry = "hello",

    # Specify your pip requirements here:
    # requirements = [
    #   "google-cloud-logging",
    # ],

    # or specify them in another file:
    # requirements_file = "//function:requirements.txt"

    # Specify a GCP project name instead of using the default:
    # gcloud_project = "my-gcp-project",

    # The function name that appears in HTTP path:
    # deploy_name = "function_name",

    # Use pubsub as a trigger instead of HTTP:
    # trigger_topic = "pubsub_topic",

    # Use GCS as a trigger instead of HTTP:
    # trigger_bucket = "my_gcs_bucket",

    # Specify the memory limit in MiB (default is 256 MiB):
    # memory = 2048,

    # Specify the timeout of the function in seconds (default is 60 s):
    # timeout = 200,

    # Print the arguments for debugging when running the rule:
    # debug = True,
)
