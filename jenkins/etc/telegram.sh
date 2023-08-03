# Telegram Function

telegram_curl() {
	local ACTION=${1}
	shift
	local HTTP_REQUEST=${1}
	shift
	if [ "$HTTP_REQUEST" != "POST_FILE" ]; then
		curl -s -X $HTTP_REQUEST "https://api.telegram.org/bot$BOT_API_KEY/$ACTION" "$@" | jq .
	else
		curl -s "https://api.telegram.org/bot$BOT_API_KEY/$ACTION" "$@" | jq .
	fi
}

telegram_main() {
	local ACTION=${1}
	local HTTP_REQUEST=${2}
	local CURL_ARGUMENTS=()
	while [ "${#}" -gt 0 ]; do
		case "${1}" in
			--animation | --audio | --document | --photo | --video )
				local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')=@"${2}")
				shift
				;;
			--* )
				if [ "$HTTP_REQUEST" != "POST_FILE" ]; then
					local CURL_ARGUMENTS+=(-d $(echo "${1}" | sed 's/--//')="${2}")
				else
					local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')="${2}")
				fi
				shift
				;;
		esac
		shift
	done
	telegram_curl "$ACTION" "$HTTP_REQUEST" "${CURL_ARGUMENTS[@]}"
}

telegram_curl_get() {
	local ACTION=${1}
	shift
	telegram_main "$ACTION" GET "$@"
}

telegram_curl_post() {
	local ACTION=${1}
	shift
	telegram_main "$ACTION" POST "$@"
}

telegram_curl_post_file() {
	local ACTION=${1}
	shift
	telegram_main "$ACTION" POST_FILE "$@"
}

tg_send_message() {
	telegram_main sendMessage POST "$@"
}

tg_edit_message_text() {
	telegram_main editMessageText POST "$@"
}

tg_send_document() {
	telegram_main sendDocument POST_FILE "$@"
}