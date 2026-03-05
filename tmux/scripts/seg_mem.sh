#!/usr/bin/env bash
# Print memory usage in GB (plain text).
# macOS: vm_stat + sysctl.  Linux: /proc/meminfo.  No bc dependency (uses awk).

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/common.sh" || exit 1

icon="$(tmux_icon mem) "

if shell_is_macos; then
	stats=$(vm_stat | tr '\n' ' ')
	bytes_per_page=$(echo "$stats" | sed -n 's/.*page size of \([0-9]*\).*/\1/p')
	mem_total_bytes=$(sysctl -n hw.memsize)
	free_pages=$(echo "$stats" | sed -n 's/.*Pages free: *\([0-9]*\).*/\1/p')
	external_pages=$(echo "$stats" | sed -n 's/.*File-backed pages: *\([0-9]*\).*/\1/p')
	[ -z "$bytes_per_page" ] && { seg_log error "bytes_per_page parse failed"; exit 1; }
	[ -z "$free_pages" ] && { seg_log error "free_pages parse failed"; exit 1; }
	[ -z "$external_pages" ] && { seg_log error "external_pages parse failed"; exit 1; }
	[ -z "$mem_total_bytes" ] && { seg_log error "hw.memsize unavailable"; exit 1; }
	mem_used_gb=$(awk -v total="$mem_total_bytes" -v free="$free_pages" -v ext="$external_pages" -v bpp="$bytes_per_page" \
		'BEGIN { used = total - (free + ext) * bpp; printf "%.1f", used / 1073741824 }')
elif shell_is_linux; then
	mem_used_gb=$(awk '
		/^MemTotal:/    { total = $2 }
		/^MemFree:/     { free = $2 }
		/^Shmem:/       { shmem = $2 }
		/^Buffers:/     { buffers = $2 }
		/^Cached:/      { cached = $2 }
		/^SReclaimable:/ { sreclaimable = $2 }
		END { used_kb = total - free + shmem - buffers - cached - sreclaimable
		      printf "%.1f", used_kb / 1048576 }
	' /proc/meminfo)
else
	exit 1
fi

[ -n "$mem_used_gb" ] || exit 1
echo "${icon}${mem_used_gb} GB"
