#!/usr/bin/env fish
# Generate the GCF shim and deployment script from Bazel zip output.

set -l temp_archive_name 'archive.zip'

set -l options \
  (fish_opt -s i -l src_zip_path       --long-only --required-val) \
  (fish_opt -s m -l module_name        --long-only --required-val) \
  (fish_opt -s f -l function_name      --long-only --required-val) \
  (fish_opt -s e -l env_vars_file      --long-only --required-val) \
  (fish_opt -s r -l requirements_file  --long-only --required-val) \
  (fish_opt -s l -l requirements       --long-only --required-val) \
  (fish_opt -s w -l workspace_name     --long-only --required-val) \
  (fish_opt -s o -l output_archive     --long-only --required-val)

argparse $options -- $argv

set output_path (echo $_flag_output_archive | cut -d '.' -f1)
set output_real_path "$output_path/runfiles/$_flag_workspace_name"

mkdir -p $output_real_path

unzip $_flag_src_zip_path "runfiles/$_flag_workspace_name/**" -d $output_path > /dev/null

if test -n "$_flag_requirements_file"
  cat $_flag_requirements_file >> $output_real_path/requirements.txt
end

if test -n "$_flag_requirements"
  echo $_flag_requirements >> $output_real_path/requirements.txt
end

if test -n "$_flag_env_vars_file"
  cat $_flag_env_vars_file >> $output_real_path/.env.yaml
end

echo "from $_flag_module_name import $_flag_function_name" > $output_real_path/main.py

pushd $output_real_path
zip -r $temp_archive_name . > /dev/null
popd
mv "$output_real_path/$temp_archive_name" $_flag_output_archive
