#!/usr/bin/env bash

set -eo pipefail

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT"; pwd`

export DORIS_HOME=`cd "${ROOT}/.."; pwd`

CLANG_FORMAT=${CLANG_FORMAT_BINARY:=$(which clang-format)}

python3 ${DORIS_HOME}/build-support/run_clang_format.py --clang_format_binary="${CLANG_FORMAT}" --source_dirs="${DORIS_HOME}/be/src,${DORIS_HOME}/be/test" --quiet

