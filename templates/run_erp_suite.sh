#!/bin/sh

set -x

if [ -z $1 ]; then
    echo "Usage: $0 <build_number>"
    exit 1
fi

report_url="{{erp_squad_url[erp_squad_environment]}}"

# The order is important.
# - erp-enterprise may modify the state of the host due to buggy tests. Run it
#   last so it doesn't impact the other tests.
plans="plans/erp/erp-functional.yaml plans/erp/erp-ltp.yaml plans/erp/erp-performance.yaml plans/erp/erp-enterprise.yaml"

root_path=/root
td_path=${root_path}/test-definitions

# Gather environmental info for erp project and environment names
[ -n "${vendor_name}" ] || vendor_name=$(slugify `cat /sys/devices/virtual/dmi/id/board_vendor`)
[ -n "${board_name}" ] || board_name=$(slugify `cat /sys/devices/virtual/dmi/id/board_name`)
os_name=$(slugify `grep ^ID= /etc/os-release | awk -F= '{print $2}'`)

cd ${td_path}
. ./automated/bin/setenv.sh

# Calculate a unique build id based on the build number but also the contents
# of the local apt-cache, so that when the available set of packages changes,
# the build id changes. Remove "^ Time" from the results because the dpkg
# status file seems to be dynamically generated and contains a timestamp.
build_id=$1-$(apt-cache dump | grep -v "^ Time" | md5sum | cut -c -8)

# Apply test plan overlay when board-specifc ovelay file exists.
overlay_arg=""
if [ -f "plans/erp/overlays/${board_name}.yaml" ]; then
    overlay_arg="-O plans/erp/overlays/${board_name}.yaml"
fi

for plan in ${plans}; do
    plan_short=$(basename -s .yaml ${plan})
    output_path=${root_path}/${build_id}-${plan_short}
    mkdir -p ${output_path}
    test-runner -o ${output_path} \
                -p ${plan} ${overlay_arg}\
                > ${output_path}/test-runner-stdout.log \
                2> ${output_path}/test-runner-stderr.log
    post-to-squad -r ${output_path}/result.json \
                  -b ${build_id} \
                  -a ${output_path}/result.csv \
                  -a ${output_path}/test-runner-stdout.log \
                  -a ${output_path}/test-runner-stderr.log \
                  -u ${report_url} \
                  -t erp-${vendor_name} \
                  -e ${board_name} \
                  -p {{erp_debian_installer_environment}}-debian \
                  > ${output_path}/post-to-squad.log 2>&1
done

# Power off SUT to release it.
poweroff
