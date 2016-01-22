#!/bin/sh
# adapted from http://sandrinodimattia.net/posting-successful-ssh-logins-to-slack/
if [ "$PAM_TYPE" != "close_session" ]; then
        url="https://hooks.slack.com/services/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"
        host="`hostname`"
    content="\"attachments\": [ { \"mrkdwn_in\": [\"text\", \"fallback\"], \"fallback\": \"SSH login: $PAM_USER connected to \`$host\`\", \"text\": \"SSH login to \`$host\`\", \"fields\": [ { \"title\": \"User\", \"value\": \"$PAM_USER\", \"short\": true }, { \"title\": \"IP Address\", \"value\": \"$PAM_RHOST\", \"short\": true } ], \"color\": \"#F35A00\" } ]"
    curl -X POST --data-urlencode "payload={\"mrkdwn\": true, \"username\": \"ssh-bot\", $content, \"icon_emoji\": \":computer:\"}" $url
fi

