#!/bin/bash

# メールサーバ(smtp/25)に対して、1時間に10件以上 "discconet from unknown"を記録した接続元を
# NetworkACLで接続拒否にする

# setting
NetworkAclId=acl-xxxxxxxx

# 拒否対象IPアドレスを /var/log/maillog から検索、なければ終了
TARGET_TIME="$(date '+%d %H' -d '1 hour ago'):"
SERACH_RESULT=$(grep "${TARGET_TIME}" /var/log/maillog | grep "disconnect from unknown" | cut -d "[" -f3 | cut -d "]" -f1 | sort | uniq -c | head -n1)
if [[ -z ${SERACH_RESULT} ]]; then
    exit 0
fi

count=$(echo ${SERACH_RESULT} | awk '{print $1}')
if [[ "${count}" -lt 10 ]]; then
    exit 0
fi

targetIp=$(echo ${SERACH_RESULT} | awk '{print $2}')

# 拒否リストは RuleNumber に 10000 ~ 29999 を利用する
# 現時点で登録されている最大の RuleNumber を検索する
max_RuleNumber=$(aws ec2 describe-network-acls --network-acl-id ${NetworkAclId} | jq -r '.NetworkAcls[].Entries[].RuleNumber' | grep -Ev "30000|32767" | sort | uniq | tail -n1)
new_RuleNumber=$((max_RuleNumber+1))
# Todo
# max_RuleNumberが29999まで埋まった場合の対応

# 拒否リストに追加
aws ec2 create-network-acl-entry --network-acl-id ${NetworkAclId} --ingress --rule-number ${new_RuleNumber} --protocol -1 --cidr-block "${targetIp}/32" --rule-action deny

# 結果をSlackに通知
function slack {
    local webhook_url="https://hooks.slack.com/services/xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz"

    TIME=$(date '+%Y/%m/%d %H' -d '1 hour ago')
    text="add IPaddr to nacl deny list 
    IP    : ${targetIp}/32
    count : ${count}"

    curl -sS -X POST --data-urlencode \
      "payload={\"text\": \"\`\`\`${text}\`\`\`\", \
                \"username\": \"AWS_script\", \
                \"icon_emoji\": \":aws:\"}" \
                "${webhook_url}" >/dev/null 2>&1
}

slack