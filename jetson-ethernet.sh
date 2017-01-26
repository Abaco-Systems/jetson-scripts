#!/bin/sh -e

export ETH=eth1
sysctl -w net.core.rmem_default=33554432
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_default=1048576
sysctl -w net.core.wmem_max=1048576

# Disable pause frame support
ethtool -A ${ETH} autoneg off rx off tx off

sudo route add -net 224.0.0.0 netmask 240.0.0.0 dev ${ETH}

sudo ethtool -G ${ETH} rx 4096
sudo ethtool -G ${ETH} tx 4096

sudo ethtool -r ${ETH}

for CPU in /sys/devices/system/cpu/cpu[0-9]*; do
	CPUID=$(basename $CPU)
	echo "CPU: $CPUID";
	if test -e $CPU/online; then
		echo "1" > $CPU/online;
	fi;
	COREID="$(cat $CPU/topology/core_id)";
	eval "COREENABLE=\"\${core${COREID}enable}\"";
	if ${COREENABLE:-true}; then
		echo "${CPU} core=${CORE} -> enable"
		eval "core${COREID}enable='false'";
	else
		echo "$CPU core=${CORE} -> disable";
		echo "0" > "$CPU/online";
	fi;
done;

exit 0
