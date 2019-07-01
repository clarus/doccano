#!/usr/bin/env bash

set -o errexit

root="$(dirname "$0")/.."
app="${root}/app"
venv="${root}/venv"

# install
"${venv}/bin/pip" install --upgrade spacy
"${venv}/bin/python" -m spacy download $2

# run
"${venv}/bin/python" -u "${app}/manage.py" spacy "$@"
