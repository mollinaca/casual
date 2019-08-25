#!/bin/bash

TARGET_TIME="$(date '+%d %H' -d '1 hour ago'):"

number_of_sent=$(grep "${TARGET_TIME}" /var/log/maillog | grep "status=sent" | grep "relay=smtp.gmail.com" | wc -l)
number_of_reject=$(grep "${TARGET_TIME}" /var/log/maillog | grep "NOQUEUE: reject: RCPT" | wc -l)

## notification
function slack {
    local webhook_url="https://hooks.slack.com/services/xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz"

    TIME=$(date '+%Y/%m/%d %H' -d '1 hour ago')
    text="number of mails around ${TIME}:xx
    sent    : ${number_of_sent}
    rejected: ${number_of_reject}"

    curl -sS -X POST --data-urlencode \
      "payload={\"text\": \"\`\`\`${text}\`\`\`\", \
                \"username\": \"mailServer_checker\", \
                \"icon_emoji\": \":mail:\"}" \
                "${webhook_url}" >/dev/null 2>&1
}

slack
