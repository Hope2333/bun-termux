#!/usr/bin/env bash
set -euo pipefail

HOSTS=("172.18.0.1" "192.168.1.164" "192.168.1.165")
PORTS=(8022 22 2222)
USER="u0_a450"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-1800}"
SLEEP_SECONDS="${SLEEP_SECONDS:-8}"

start_ts="$(date +%s)"

probe() {
	local h="$1"
	local p="$2"
	python3 - "$h" "$p" <<'PY'
import socket, sys
h=sys.argv[1]
p=int(sys.argv[2])
s=socket.socket(); s.settimeout(0.6)
try:
    s.connect((h,p))
    print('OPEN')
except Exception:
    print('CLOSED')
finally:
    s.close()
PY
}

while true; do
	now="$(date +%s)"
	elapsed="$((now - start_ts))"
	if [ "$elapsed" -ge "$MAX_WAIT_SECONDS" ]; then
		echo "[oct] timeout waiting for remote after ${elapsed}s"
		exit 124
	fi

	for host in "${HOSTS[@]}"; do
		for port in "${PORTS[@]}"; do
			if [ "$(probe "$host" "$port")" = "OPEN" ]; then
				echo "[oct] found reachable candidate ${host}:${port}, trying ssh auth"
				if ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -p "$port" "${USER}@${host}" 'echo __OK__' >/tmp/oct_ssh_probe.out 2>/tmp/oct_ssh_probe.err; then
					echo "[oct] ssh auth succeeded for ${host}:${port}"
					/home/miao/termux-lab/scripts/oct-remote-apply-and-build.sh "$host" "$port" "$USER"
					exit 0
				fi

				if grep -qi 'password' /tmp/oct_ssh_probe.err 2>/dev/null; then
					echo "[oct] host alive but password auth required for ${host}:${port}"
					echo "[oct] run manual: ssh -p ${port} ${USER}@${host}"
				else
					echo "[oct] ssh probe failed for ${host}:${port}"
				fi
			fi
		done
	done

	sleep "$SLEEP_SECONDS"
done
