#!/usr/bin/env bash
# check-rebrand.sh — i18n 리브랜딩 누락 검사
#
# assets/base/i18n/*.json 전 로케일에서 금지 문자열(Mattermost, 매터모스트)을 찾는다.
# CLAUDE.md 리브랜딩 규칙의 예외 키 3개(settings.notice_text, settings.about.powered_by,
# about.teamEditionLearn)와 이모지 코드 `:mattermost:`는 허용한다.
#
# upstream sync 세션 마감 게이트에서 실행한다 — upstream이 추가한 신규 문자열에
# 리브랜딩(O'talk / OKR Best Inc) 재적용이 누락되면 여기서 걸린다.
#
# 사용법: check-rebrand.sh   (위반 없으면 exit 0, 있으면 위반 목록 출력 후 exit 1)

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

node - <<'EOF'
const fs = require('fs');
const path = require('path');

const I18N_DIR = 'assets/base/i18n';
const FORBIDDEN = /Mattermost|매터모스트/;
const ALLOWED_KEYS = new Set([
    'settings.notice_text',
    'settings.about.powered_by',
    'about.teamEditionLearn',
]);

let violations = 0;
for (const file of fs.readdirSync(I18N_DIR).filter((f) => f.endsWith('.json')).sort()) {
    const data = JSON.parse(fs.readFileSync(path.join(I18N_DIR, file), 'utf8'));
    for (const [key, value] of Object.entries(data)) {
        if (typeof value !== 'string' || ALLOWED_KEYS.has(key)) {
            continue;
        }
        // 이모지 코드 :mattermost: 는 허용 — 제거한 뒤 검사한다
        const stripped = value.replace(/:mattermost:/g, '');
        if (FORBIDDEN.test(stripped)) {
            violations += 1;
            console.log(`${file}  ${key}: ${JSON.stringify(value).slice(0, 100)}`);
        }
    }
}

if (violations > 0) {
    console.error(`\n리브랜딩 누락 ${violations}건 — 위 키의 문자열을 O'talk 규칙으로 수정해야 한다.`);
    process.exit(1);
}
console.log('check-rebrand: OK (위반 없음)');
EOF
