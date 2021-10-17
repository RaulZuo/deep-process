#!/usr/bin/bash

# DEEP_PROCESS 项目源码根目录
DEEP_PROCESS_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..

# 生成文件存放目录
LOCAL_OUTOUT_ROOT="${DEEP_PROCESS_ROOT}/${OUT_DIR:-_output}"