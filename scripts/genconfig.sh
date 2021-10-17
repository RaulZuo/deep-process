#!/usr/bin/env bash

# 本脚本功能：根据 scripts/environment.sh 配置，生成 DEEP_PROCESS 组件 DEEP_PROCESS 组件 YAML 配置问卷。
# 示例：genconfig.sh scripts/environment.sh configs/deep-apiserver.yaml

env_file="$1"
template_file="$2"

DEEP_PROCESS_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

source "${DEEP_PROCESS_ROOT}/scripts/lib/init.sh"
