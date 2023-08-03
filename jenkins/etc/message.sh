build_message() {
	if [ "$CI_MESSAGE_ID" = "" ]; then
CI_MESSAGE_ID=$(tg_send_message --chat_id "$CHAT_ID" --text "<b>====== Starting Build Komodo 🦎 ======</b>
<b>ROM Name:</b> <code>${ROM_NAME}</code>
<b>Branch:</b> <code>${BRANCH_MANIFEST}</code>
<b>Device:</b> <code>${DEVICE}</code>
<b>Type:</b> <code>$build_type</code>
<b>Command:</b> <code>$target_command</code>
<b>Cleaning:</b> <code>$make_clean</code>
<b>Job:</b> <code>$jobs Paralel processing</code>
<b>Upload to SF:</b> <code>$upload_to_sf</code>
<b>Running on:</b> <code>$server</code>
<b>Started at</b> <code>$DATE</code>

<b>Status:</b> $1" --parse_mode "html" | jq .result.message_id)
	else
tg_edit_message_text --chat_id "$CHAT_ID" --message_id "$CI_MESSAGE_ID" --text "<b>====== Starting Build Komodo 🦎 ======</b>
<b>ROM Name:</b> <code>${ROM_NAME}</code>
<b>Branch:</b> <code>${BRANCH_MANIFEST}</code>
<b>Device:</b> <code>${DEVICE}</code>
<b>Type:</b> <code>$build_type</code>
<b>Command:</b> <code>$target_command</code>
<b>Cleaning:</b> <code>$make_clean</code>
<b>Job:</b> <code>$jobs Paralel processing</code>
<b>Upload to SF:</b> <code>$upload_to_sf</code>
<b>Running on:</b> <code>$server</code>
<b>Started at</b> <code>$DATE</code>

<b>Status:</b> $1" --parse_mode "html"
	fi
}