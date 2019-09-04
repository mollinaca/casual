#!/bin/bash

# * メールサーバ(smtp/25)に対して、1時間に3件以上 "discconet from unknown"を記録した接続元
# * secureログに対して、1時間に3件以上 "Invalid user" を記録した接続元
# を、NetworkACLで接続拒否にする

# setting
NetworkAclId=acl-xxxxxxxx

function find_from_maillog {
    # 拒否対象IPアドレスを /var/log/maillog から検索

    local TARGET_TIME
    local SERACH_RESULT

    TARGET_TIME="$(date '+%d %H' -d '1 hour ago'):"
    SERACH_RESULT=$(grep "${TARGET_TIME}" /var/log/maillog | grep "disconnect from unknown" | cut -d "[" -f3 | cut -d "]" -f1 | sort | uniq -c | head -n1)
    if [[ -z ${SERACH_RESULT} ]]; then
        return 0
    fi

    local count    
    count=$(echo ${SERACH_RESULT} | awk '{print $1}')
    if [[ "${count}" -lt 3 ]]; then
        return 0
    fi

    echo ${SERACH_RESULT} | awk '{print $2}'
}

function find_from_securelog {
    # 拒否対象IPアドレスを /var/log/secure から検索

    local TARGET_TIME
    local SERACH_RESULT

    TARGET_TIME=$(date '+%e %H' -d '1 hour ago')
    SERACH_RESULT=$(grep "${TARGET_TIME}" /var/log/secure | grep "Invalid user" | awk '{print $10}' | sort | uniq -c | head -n1)
    if [[ -z ${SERACH_RESULT} ]]; then
        return 0
    fi

    local count
    count=$(echo ${SERACH_RESULT} | awk '{print $1}')
    if [[ "${count}" -lt 3 ]]; then
        return 0
    fi

    echo ${SERACH_RESULT} | awk '{print $2}'
}

function add_nacl_deny_list {
    local tagetIp
    targetIp="${1}"

    # 拒否リストは RuleNumber に 10000 ~ 29999 を利用する
    # 現時点で登録されている最大の RuleNumber を検索する
    max_RuleNumber=$(aws ec2 describe-network-acls --network-acl-id ${NetworkAclId} | jq -r '.NetworkAcls[].Entries[].RuleNumber' | grep -Ev "30000|32767" | sort | uniq | tail -n1)
    new_RuleNumber=$((max_RuleNumber+1))
    # Todo
    # max_RuleNumberが29999まで埋まった場合の対応

    # 拒否リストに追加
    aws ec2 create-network-acl-entry --network-acl-id ${NetworkAclId} --ingress --rule-number ${new_RuleNumber} --protocol -1 --cidr-block "${targetIp}/32" --rule-action deny >/dev/null 2>&1
    echo "${new_RuleNumber}"
}

# 結果をSlackに通知
function slack {
    local webhook_url="https://hooks.slack.com/services/xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz"
    local description
    description="${1}"

    TIME=$(date '+%Y/%m/%d %H' -d '1 hour ago')
    text="add IPaddr to nacl deny list 
    IP    : ${targetIp}/32
    ${description}"

    curl -sS -X POST --data-urlencode \
      "payload={\"text\": \"\`\`\`${text}\`\`\`\", \
                \"username\": \"AWS_script\", \
                \"icon_emoji\": \":aws:\"}" \
                "${webhook_url}" >/dev/null 2>&1
}

targetIp=$(find_from_maillog)
if [[ ! -z "${targetIp}" ]]; then
    add_nacl_deny_list "${targetIp}"
    slack "from mail log"
fi

targetIp=$(find_from_securelog)
if [[ ! -z "${targetIp}" ]]; then
    add_nacl_deny_list "${targetIp}"
    slack "from secure log"
fi
