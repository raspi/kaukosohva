#!/bin/bash

set -eu
set -o pipefail

find . -type f -iname "*.dot" -exec dot -Tpng -O "{}" \;
