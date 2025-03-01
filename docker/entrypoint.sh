#!/bin/bash
# Source the virtual environment
source /build/tmp/virtualenv.py3/bin/activate
# Execute the command passed to the container
exec "$@"
