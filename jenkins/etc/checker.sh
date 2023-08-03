# Build status checker
function statusBuild() {
    if [[ $retVal -eq 8 ]]; then
        build_message "Build Aborted 😡 with Code Exit ${retVal}, BRANCH_MANIFEST not set on jenkins.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}.
Check channel for more info.
Sudah kubilang yang teliti 😡"
        echo "Build Aborted"
        tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -eq 3 ]]; then
        build_message "Build Aborted 😤 with Code Exit ${retVal}, SF_PASS_RELEASE not set on jenkins.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}.
Check channel for more info"
        echo "Build Aborted"
        tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -eq 5 ]]; then
        build_message "Build Aborted 😑 with Code Exit ${retVal}, SF_PASS_TEST not set on jenkins.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}.
Check channel for more info"
        echo "Build Aborted"
        tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -eq 141 ]]; then
        build_message "Build Aborted 👎 with Code Exit ${retVal}, See log.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}.
Check channel for more info"
        echo "Build Aborted"
        tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -ne 0 ]]; then
        build_message "Build Error 💔 with Code Exit ${retVal}, See log.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Error 💔 with Code Exit ${retVal}.
Check channel for more info"
        echo "Build Error"
        tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [ "$target_command" = "komodo" ]; then
       OTA=$(find $OUT -name "$ROM_NAME-*json")
       tg_send_document --chat_id "$CHAT_ID" --document "$OTA" --reply_to_message_id "$CI_MESSAGE_ID"
    fi
    build_message "Build success ❤️"
    tg_send_message --chat_id "$CHAT_ID_SECOND" --text "Build Success ❤️.
Check channel for more info"
}
