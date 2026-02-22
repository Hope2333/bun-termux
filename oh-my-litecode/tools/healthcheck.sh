#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

redact() {
	local v="${1:-}"
	if [[ -z "${v}" ]]; then
		printf '%s' "(unset)"
		return 0
	fi
	if [[ ${#v} -le 8 ]]; then
		printf '%s' "***"
		return 0
	fi
	printf '%s...%s' "${v:0:3}" "${v: -2}"
}

echo "[env] CONTEXT7_API_KEY=$(redact "${CONTEXT7_API_KEY:-}")"
echo "[env] EXA_API_KEY=$(redact "${EXA_API_KEY:-}")"
echo "[env] OPENAI_API_KEY=$(redact "${OPENAI_API_KEY:-}")"
echo ""

echo "[net] context7 handshake..."
curl -I -sS "https://mcp.context7.com/mcp" | sed -n '1,12p' || echo "WARN: context7 handshake failed"
echo ""

if command -v qwen >/dev/null 2>&1; then
	echo "[qwen] version: $(qwen --version 2>/dev/null || true)"
	echo "[qwen] mcp list:"
	qwen mcp list || true
	echo ""
fi

if command -v qwenx >/dev/null 2>&1; then
	echo "[qwenx] version: $(qwenx --version 2>/dev/null || true)"
	echo "[qwenx] mcp list:"
	qwenx mcp list || true
	echo ""
fi

if command -v geminix >/dev/null 2>&1; then
	echo "[geminix] version: $(geminix --version 2>/dev/null || true)"
	echo "[geminix] mcp list:"
	geminix mcp list || true
	echo ""
fi

echo "DONE"
