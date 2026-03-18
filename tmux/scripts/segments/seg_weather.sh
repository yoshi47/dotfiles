#!/usr/bin/env bash
# Weather segment: Open-Meteo API with Nerd Font icons + cache.
# Outputs plain text (icon + temp) like other segments. Silent on failure.

# shellcheck disable=SC1091
tmux_icon() {
	case "$1" in weather_clear) echo "*" ;; weather_cloud) echo "~" ;;
		weather_rain) echo "R" ;; weather_snow) echo "S" ;;
		weather_thunder) echo "!" ;; weather_fog) echo "=" ;;
		weather_*|*) echo "?" ;; esac
}
seg_log() { :; }
source "$(dirname "$0")/../common.sh" 2>/dev/null
CACHE_FILE="/tmp/tmux-weather.cache"
COORDS_CACHE="/tmp/tmux-weather-coords.cache"
CACHE_TTL=900  # 15 minutes
LOCATION="${TMUX_WEATHER_LOCATION:-Tokyo}"
TIMEOUT=5
FALLBACK_ICON="$(tmux_icon weather_unknown)"
FALLBACK_TEMP="--"
WEATHER_THUNDER="$(tmux_icon weather_thunder)"
WEATHER_SNOW="$(tmux_icon weather_snow)"
WEATHER_RAIN="$(tmux_icon weather_rain)"
WEATHER_FOG="$(tmux_icon weather_fog)"
WEATHER_CLOUD="$(tmux_icon weather_cloud)"
WEATHER_CLEAR="$(tmux_icon weather_clear)"

# Resolve city name to lat/lon via Open-Meteo Geocoding API (cached).
resolve_coords() {
	if [ -f "$COORDS_CACHE" ]; then
		local cached_loc
		cached_loc=$(head -1 "$COORDS_CACHE")
		if [ "$cached_loc" = "$LOCATION" ]; then
			LAT=$(sed -n '2p' "$COORDS_CACHE")
			LON=$(sed -n '3p' "$COORDS_CACHE")
			seg_log info "coords cache hit: ${LAT},${LON}"
			return 0
		fi
	fi
	local geo
	geo=$(curl -s --max-time "$TIMEOUT" "https://geocoding-api.open-meteo.com/v1/search?name=${LOCATION}&count=1")
	LAT=$(echo "$geo" | jq -r '.results[0].latitude // empty')
	LON=$(echo "$geo" | jq -r '.results[0].longitude // empty')
	if [ -z "$LAT" ] || [ -z "$LON" ]; then
		seg_log warn "geocoding failed for: ${LOCATION}"
		return 1
	fi
	printf '%s\n%s\n%s\n' "$LOCATION" "$LAT" "$LON" > "$COORDS_CACHE"
	seg_log info "geocoding ok: ${LOCATION} → ${LAT},${LON}"
}

# Map WMO weather code to Nerd Font icon.
weather_icon() {
	case "$1" in
		0|1)        echo "$WEATHER_CLEAR" ;;
		2|3)        echo "$WEATHER_CLOUD" ;;
		45|48)      echo "$WEATHER_FOG" ;;
		51|53|55|56|57|61|63|65|66|67|80|81|82) echo "$WEATHER_RAIN" ;;
		71|73|75|77|85|86) echo "$WEATHER_SNOW" ;;
		95|96|99)   echo "$WEATHER_THUNDER" ;;
		*)          echo "$FALLBACK_ICON" ;;
	esac
}

emit_weather() {
	local code="$1"
	local temp="$2"
	local icon
	icon=$(weather_icon "$code")
	[ -z "$icon" ] && icon="$FALLBACK_ICON"
	[ -z "$temp" ] && temp="$FALLBACK_TEMP"
	echo "${icon} ${temp}"
}

# --- Stale-while-error cache logic ---

# Try cache first (line1=weather_code, line2=temp_formatted)
read_cache() {
	[ -f "$CACHE_FILE" ] || return 1
	local code temp
	code=$(sed -n '1p' "$CACHE_FILE")
	temp=$(sed -n '2p' "$CACHE_FILE")
	[ -n "$code" ] && [ -n "$temp" ] || return 1
	echo "$code"
	echo "$temp"
}

emit_from_cache() {
	local cached
	cached=$(read_cache) || return 1
	emit_weather "$(echo "$cached" | head -1)" "$(echo "$cached" | tail -1)"
}

cache_age() {
	[ -f "$CACHE_FILE" ] || return 1
	echo $(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
}

# Fresh cache → use it
age=$(cache_age)
if [ -n "$age" ] && [ "$age" -lt "$CACHE_TTL" ]; then
	if emit_from_cache; then
		seg_log info "cache hit (age=${age}s)"
		exit 0
	fi
fi

# Cache miss or stale → fetch
if ! resolve_coords; then
	# Geocoding failed — try stale cache
	if emit_from_cache; then
		seg_log warn "geocoding failed, using stale cache"
		exit 0
	fi
	seg_log warn "geocoding failed, no cache — fallback"
	emit_weather "" "$FALLBACK_TEMP"
	exit 0
fi

raw=$(curl -s --max-time "$TIMEOUT" \
	"https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&timezone=auto")
weather_code=$(echo "$raw" | jq -r '.current.weather_code // empty')
temp_raw=$(echo "$raw" | jq -r '.current.temperature_2m // empty')

if [ -n "$weather_code" ] && [ -n "$temp_raw" ]; then
	temp=$(printf "%.0f°C" "$temp_raw")
	seg_log info "fetch ok: code=${weather_code}, temp=${temp}"
	printf '%s\n%s\n' "$weather_code" "$temp" > "$CACHE_FILE"
	emit_weather "$weather_code" "$temp"
	exit 0
fi

# Fetch failed — stale-while-error
if emit_from_cache; then
	seg_log warn "fetch failed, using stale cache"
	exit 0
fi

seg_log warn "no cache — fallback"
emit_weather "" "$FALLBACK_TEMP"
