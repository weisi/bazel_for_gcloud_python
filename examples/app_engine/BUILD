load("@bazel_for_gcloud_python//infra/serverless:gae_rules.bzl", "py_app_engine")

py_library(
    name = "gae_utils",
    srcs = ["gae_utils.py"],
    deps = [
        "//function:gcf_utils",
    ],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "app",
    srcs = [
        "app.py",
    ],
    data = [
        "static/file.html",
    ],
    deps = [
        ":gae_utils",
    ],
)

# 'bazel run' this rule to trigger deployment.
py_app_engine(
    # Required parameters:
    name = "app_deploy",
    src = ":app",
    descriptor = "app.yaml",
    entry = "app",

    # Specify your pip requirements here
    requirements = [
        # flask is required.
        "flask",
    ],

    # Specify a GCP project name instead of using the default:
    # gcloud_project = "my-gcp-project",

    # Print the arguments for debugging when running the rule:
    # debug = True,
)
