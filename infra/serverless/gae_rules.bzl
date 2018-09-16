'''Starlark rule for packaging Python 3 Google App Engine services.'''

SRC_ZIP_EXTENSION = 'zip'
SRC_PY_EXTENSION = 'py'

DEPLOY_SCRIPT_TEMPLATE = '''#!/usr/bin/env fish
set gae_archive (status --current-filename | sed 's/\.fish$/\.zip/' | xargs realpath)
set temp_dir (mktemp -d)
unzip $gae_archive -d $temp_dir > /dev/null
{gcloud_cmdline} $temp_dir/app.yaml
rm -rf $temp_dir
'''

def _compute_module_name(f):
  return f.basename.split('.')[0]

def _compute_module_path(f):
  components = []
  components.extend(f.dirname.split('/'))
  components.append(_compute_module_name(f))
  return '.'.join(components)

def _py_app_engine_impl(ctx):
  src_zip = None
  src_py = None
  for f in ctx.attr.src.files.to_list():
    if f.extension == SRC_ZIP_EXTENSION:
      src_zip = f
    if f.extension == SRC_PY_EXTENSION:
      src_py = f
  if not src_zip:
    fail('ZIP src input not found.', 'src')
  if not src_py:
    fail('PY src input not found.', 'src')

  args = []

  args.extend([
    '--src_zip_path',
    src_zip.path,
    '--module_name',
    ctx.attr.module or _compute_module_path(src_py),
    '--function_name',
    ctx.attr.entry,
    '--output_archive',
    ctx.outputs.code_archive.path,
    '--descriptor_file',
    ctx.attr.descriptor.files.to_list()[0].path,
    '--workspace_name',
    ctx.workspace_name,
  ])

  if ctx.attr.requirements_file:
    if len(ctx.attr.requirements_file.files.to_list()) > 1:
      fail('There should be only 1 requirements file input.', 'requirements_file')
    args.extend([
      '--requirements_file',
      ctx.attr.requirements_file.files.to_list()[0].path,
    ])

  if ctx.attr.requirements:
    args.extend([
      '--requirements',
      '\n'.join(ctx.attr.requirements),
    ])

  gcloud_cmdline = []
  gcloud_cmdline.extend(['gcloud'])
  if ctx.attr.gcloud_project:
    gcloud_cmdline.extend(['--project', ctx.attr.gcloud_project])
  gcloud_cmdline.extend(['app', 'deploy'])
  if ctx.attr.version:
    gcloud_cmdline.extend(['--version', ctx.attr.version])
  gcloud_cmdline.extend(['--quiet'])

  deploy_script_content = DEPLOY_SCRIPT_TEMPLATE.format(gcloud_cmdline=' '.join(gcloud_cmdline))
  ctx.actions.write(output = ctx.outputs.deploy, content = deploy_script_content)

  if ctx.attr.debug:
    print('args: {}'.format(args))

  inputs = ctx.attr.src.files.to_list()
  inputs += ctx.attr.descriptor.files.to_list()
  if ctx.attr.requirements_file:
    inputs += ctx.attr.requirements_file.files.to_list()
  ctx.actions.run(
    inputs =  inputs,
    outputs = [ctx.outputs.code_archive],
    arguments = args,
    progress_message = 'Creating app engine deployment package %s' % ctx.outputs.code_archive.short_path,
    executable = ctx.executable._make_package_tool,
  )

  runfiles = ctx.runfiles(files = [ctx.outputs.code_archive])
  return [DefaultInfo(executable = ctx.outputs.deploy, runfiles = runfiles)]

# 'bazel run' this rule to trigger deployment.
py_app_engine = rule(
  implementation = _py_app_engine_impl,
  attrs = {
    'src': attr.label(mandatory = True),
    'descriptor': attr.label(mandatory = True, allow_files = True),
    'module': attr.string(),  # optional. Can be inferred.
    'version': attr.string(),
    'entry': attr.string(mandatory = True),
    'requirements_file': attr.label(allow_files = True),
    'requirements': attr.string_list(),
    'gcloud_project': attr.string(),
    'debug': attr.bool(),
    '_make_package_tool': attr.label(
      executable = True,
      cfg = 'host',
      allow_files = True,
      default = Label('//infra/serverless:make_gae_package'),
    ),
  },
  outputs = {
    'code_archive': '%{name}.zip',
    'deploy': '%{name}.fish',
  },
  executable = True,
)
