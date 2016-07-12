#!/usr/bin/env bash

# fail on any command exiting non-zero
set -eo pipefail

if [[ -z $DOCKER_BUILD ]]; then
  echo
  echo "Note: this script is intended for use by the Dockerfile and not as a way to build the controller locally"
  echo
  exit 1
fi

# install required system packages
apk add --no-cache \
  build-base \
  libffi-dev \
  libpq \
  openldap \
  openldap-dev \
  postgresql-dev \
  python \
  python-dev

# install pip
curl -sSL https://bootstrap.pypa.io/get-pip.py | python - pip==8.1.1

# add a deis user
adduser deis -D -h /app -s /bin/bash

# create a /app directory for storing application data
mkdir -p /app && chown -R deis:deis /app

# create directory for confd templates
mkdir -p /templates && chown -R deis:deis /templates

# install dependencies
pip install --disable-pip-version-check --no-cache-dir -r /app/requirements.txt

# install mysql-connector-python
curl -Lo mysql-connector-python-2.1.3.tar.gz https://github.com/mysql/mysql-connector-python/archive/2.1.3.tar.gz
tar -xzf mysql-connector-python-2.1.3.tar.gz
sed -i 's/SchemaEditorClass = DatabaseSchemaEditor//' mysql-connector-python-2.1.3/lib/mysql/connector/django/base.py # hack for django 1.6
cd mysql-connector-python-2.1.3 && python setup.py install && cd ../
rm -rf mysql-connector-python*

# cleanup.
apk del --no-cache \
  build-base \
  libffi-dev \
  openldap-dev \
  postgresql-dev \
  python-dev
