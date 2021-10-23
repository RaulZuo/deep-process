#!/usr/bin/env bash

# The root of the build/dist directory
DEEP_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..

[[ -z ${COMMON_SOURCED} ]] && source ${DEEP_ROOT}/scripts/install/common.sh

# 安装后打印必要的信息
function deep::mariadb::info() {
cat << EOF
MariaDB Login: mysql -h127.0.0.1 -u${MARIADB_ADMIN_USERNAME} -p'${MARIADB_ADMIN_PASSWORD}'
EOF
}

# 安装
function deep::mariadb::install()
{
  # 1. 配置 MariaDB 10.5 Yum 源
  echo ${LINUX_PASSWORD} | sudo -S bash -c "cat << 'EOF' > /etc/yum.repos.d/mariadb-10.5.repo
# MariaDB 10.5 CentOS repository list - created 2020-10-23 01:54 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = https://mirrors.aliyun.com/mariadb/yum/10.5/centos8-amd64/
module_hotfixes=1
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=0
EOF"

  # 2. 安装MariaDB和MariaDB客户端
  deep::common::sudo "yum -y install MariaDB-server MariaDB-client"

  # 3. 启动 MariaDB，并设置开机启动
  deep::common::sudo "systemctl enable mariadb"
  deep::common::sudo "systemctl start mariadb"

  # 4. 设置root初始密码
  deep::common::sudo "mysqladmin -u${MARIADB_ADMIN_USERNAME} password ${MARIADB_ADMIN_PASSWORD}"

  deep::mariadb::status || return 1
  deep::mariadb::info
  deep::log::info "install MariaDB successfully"
}

# 卸载
function deep::mariadb::uninstall()
{
  set +o errexit
  deep::common::sudo "systemctl stop mariadb"
  deep::common::sudo "systemctl disable mariadb"
  deep::common::sudo "yum -y remove MariaDB-server MariaDB-client"
  deep::common::sudo "rm -rf /var/lib/mysql"
  deep::common::sudo "rm -f /etc/yum.repos.d/mariadb-10.5.repo"
  set -o errexit
  deep::log::info "uninstall MariaDB successfully"
}

# 状态检查
function deep::mariadb::status()
{
  # 查看mariadb运行状态，如果输出中包含active (running)字样说明mariadb成功启动。
  systemctl status mariadb |grep -q 'active' || {
    deep::log::error "mariadb failed to start, maybe not installed properly"
    return 1
  }

  mysql -u${MARIADB_ADMIN_USERNAME} -p${MARIADB_ADMIN_PASSWORD} -e quit &>/dev/null || {
    deep::log::error "can not login with root, mariadb maybe not initialized properly"
    return 1
  }
}

if [[ "$*" =~ deep::mariadb:: ]];then
  eval $*
fi
