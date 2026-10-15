#!/usr/bin/env bash
# upstream-sync.sh — okrbest-mobile upstream 선별 반영 도구 (기계적 신호 수집 전용)
#
# 판단(cherry-pick/adapt/exclude/spec)은 /speckit-sync 스킬의 LLM 워크플로가 수행한다.
# 이 스크립트는 목록 갱신과 판단 재료(신호) 수집만 담당한다.
#
# 사용법:
#   upstream-sync.sh update            미반영 목록 재생성 (fetch + 차감 규칙 적용)
#   upstream-sync.sh status            남은 개수·마지막 반영 커밋·부록 집계
#   upstream-sync.sh next [n]          오래된 순 앞 n개 (기본 1) full hash + 제목
#   upstream-sync.sh signals <hash>    LLM 판단 재료 출력 (충돌 예측·보호/위험 경로·포크 이력)
#   upstream-sync.sh exclude <hash> <사유>     제외 부록에 기록 후 update
#   upstream-sync.sh to-spec <hash> <specID>   spec 부록에 기록 후 update
#
# okrbest(server/webapp)의 동명 스크립트를 mobile 조건으로 포팅했다: upstream-main
# (mattermost-mobile) 기준, upstream 과거 merge 커밋 제외(--no-merges), 모바일 보호
# 경로(리브랜드 자산·i18n·앱 식별자·배포)와 위험 경로(DB 마이그레이션·네이티브) 신호.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
LEDGER="$REPO_ROOT/docs/upstream-main-unmerged-commits.md"
UPSTREAM_BRANCH="upstream-main"
UPSTREAM_REMOTE_REF="upstream/main"
UPSTREAM_URL="https://github.com/mattermost/mattermost-mobile"
BASE_BRANCH="${SYNC_BASE_BRANCH:-main}"   # 테스트 시 오버라이드 가능

cd "$REPO_ROOT"

# ---------- 공통 ----------

# main..upstream-main 중 "처리 완료"로 간주해 차감할 full hash 목록
processed_hashes() {
    {
        # 1) picked/adapted: 포크 자체 커밋($UPSTREAM_BRANCH..$BASE_BRANCH) 본문의 cherry-pick/Upstream 참조
        #    (upstream 커밋 자체의 릴리스 브랜치 cherry-pick 문구 오검출 방지)
        git log "$UPSTREAM_BRANCH..$BASE_BRANCH" --grep='cherry picked from commit' --grep='Upstream: ' \
            --pretty=format:'%B' 2>/dev/null |
            grep -oE '(cherry picked from commit |Upstream: '"$UPSTREAM_URL"'/commit/)[0-9a-f]{40}' |
            grep -oE '[0-9a-f]{40}$' || true
        # 2) excluded / spec: ledger 부록 섹션의 링크 URL 속 full hash
        if [[ -f "$LEDGER" ]]; then
            awk '/^## (제외된 커밋|spec 전환 커밋)/,0' "$LEDGER" |
                grep -oE "$UPSTREAM_URL/commit/[0-9a-f]{40}" |
                grep -oE '[0-9a-f]{40}' || true
        fi
    } | sort -u
}

# 부록 섹션 보존 추출 (없으면 기본 골격)
appendix_section() {
    local title="$1"  # "제외된 커밋" | "spec 전환 커밋"
    local extra_col="$2"  # "사유" | "spec"
    if [[ -f "$LEDGER" ]] && grep -q "^## $title" "$LEDGER"; then
        awk -v t="^## $title" '$0 ~ t {f=1} f && /^## / && $0 !~ t {exit} f {print}' "$LEDGER"
    else
        printf '## %s\n\n| 커밋 해시 | 커밋 제목 | %s |\n|---|---|---|\n' "$title" "$extra_col"
    fi
}

md_escape_row() {
    # stdin: full\x1fsubject\x1fdate → markdown 표 행
    while IFS=$'\x1f' read -r full subj date; do
        subj="${subj//\\/\\\\}"
        subj="${subj//|/\\|}"
        subj="${subj//[/\\[}"
        subj="${subj//]/\\]}"
        printf '| %s | [%s](%s/commit/%s) | %s |\n' "${full:0:8}" "$subj" "$UPSTREAM_URL" "$full" "$date"
    done
}

# ---------- update ----------

cmd_update() {
    git fetch upstream --quiet || echo "WARN: git fetch upstream 실패 — 로컬 상태로 진행" >&2
    # 로컬 추적 브랜치 fast-forward (체크아웃 없이)
    if git rev-parse --verify -q "$UPSTREAM_REMOTE_REF" >/dev/null; then
        git update-ref "refs/heads/$UPSTREAM_BRANCH" "$(git rev-parse "$UPSTREAM_REMOTE_REF")"
    fi

    local processed pending_rows last_synced_line total
    processed="$(processed_hashes)"

    # 오래된 순 미반영 목록 (처리 완료 차감, upstream의 merge 커밋은 cherry-pick 대상이 아니므로 제외)
    pending_rows="$(
        git log "$BASE_BRANCH..$UPSTREAM_BRANCH" --no-merges --reverse --date=format:%Y-%m-%d \
            --pretty=tformat:'%H%x1f%s%x1f%ad' |
        while IFS=$'\x1f' read -r full subj date; do
            grep -qx "$full" <<<"$processed" && continue
            printf '%s\x1f%s\x1f%s\n' "$full" "$subj" "$date"
        done | md_escape_row
    )"
    total="$(grep -c '^|' <<<"$pending_rows" || true)"
    [[ -z "$pending_rows" ]] && total=0

    # 마지막 반영 커밋 = 분기점 이후 처리된 것 중 가장 최근(오래된 순 진행 가정), 없으면 merge-base
    local last_hash
    last_hash="$(
        git log "$BASE_BRANCH..$UPSTREAM_BRANCH" --no-merges --reverse --pretty=tformat:'%H' |
        while read -r full; do
            if grep -qx "$full" <<<"$processed"; then echo "$full"; fi
        done | tail -1
    )"
    [[ -z "$last_hash" ]] && last_hash="$(git merge-base "$BASE_BRANCH" "$UPSTREAM_BRANCH")"
    last_synced_line="$(git log -1 --date=format:%Y-%m-%d --pretty=tformat:'%H%x1f%s%x1f%ad' "$last_hash" | md_escape_row |
        sed 's/^| /**마지막 반영 커밋:** `/; s/ | \[/` | [/; s/ |$//')"

    local excluded_sec spec_sec memo_sec=""
    excluded_sec="$(appendix_section "제외된 커밋" "사유")"
    spec_sec="$(appendix_section "spec 전환 커밋" "spec")"
    # 사람이 작성하는 자유 형식 메모 절 — 있으면 그대로 보존한다
    if [[ -f "$LEDGER" ]] && grep -q "^## 후속 작업 메모" "$LEDGER"; then
        memo_sec="$(awk '/^## 후속 작업 메모/{f=1; print; next} f && /^## /{exit} f{print}' "$LEDGER")"
    fi

    {
        echo "# upstream-main 미반영 커밋 목록"
        echo
        echo "\`$BASE_BRANCH\`에 반영되지 않은 \`$UPSTREAM_BRANCH\`(mattermost/mattermost-mobile) 커밋 목록 (오래된 순)."
        echo "\`/speckit-sync\` 스킬이 이 목록을 갱신·소비한다. 반영 완료된 커밋은 목록에서 제거된다."
        echo
        echo "- 갱신일: $(date '+%Y-%m-%d %H:%M')"
        echo "- 기준: \`git log --no-merges $BASE_BRANCH..$UPSTREAM_BRANCH\` − 처리 완료(cherry-pick/adapt 커밋 본문의 upstream 참조, 하단 부록의 제외·spec 전환)"
        echo "- 남은 커밋: ${total}개"
        echo
        echo "$last_synced_line"
        echo
        echo "| 커밋 해시 | 커밋 제목 | 커밋 일자 |"
        echo "|---|---|---|"
        [[ -n "$pending_rows" ]] && echo "$pending_rows"
        echo
        echo "$excluded_sec"
        echo
        echo "$spec_sec"
        if [[ -n "$memo_sec" ]]; then
            echo
            echo "$memo_sec"
        fi
    } >"$LEDGER"

    echo "updated: $LEDGER (남은 커밋 ${total}개)"
}

# ---------- status ----------

cmd_status() {
    [[ -f "$LEDGER" ]] || { echo "ledger 없음 — 먼저 update 실행" >&2; exit 1; }
    grep -E '^- 남은 커밋|^\*\*마지막 반영 커밋' "$LEDGER"
    local ex sp
    ex="$(awk '/^## 제외된 커밋/,/^## spec 전환 커밋/' "$LEDGER" | grep -c '^| [0-9a-f]' || true)"
    sp="$(awk '/^## spec 전환 커밋/,0' "$LEDGER" | grep -c '^| [0-9a-f]' || true)"
    echo "- 제외된 커밋: ${ex}개 / spec 전환: ${sp}개"
}

# ---------- next ----------

cmd_next() {
    local n="${1:-1}" processed
    processed="$(processed_hashes)"
    git log "$BASE_BRANCH..$UPSTREAM_BRANCH" --no-merges --reverse --date=format:%Y-%m-%d \
        --pretty=tformat:'%H%x1f%s%x1f%ad' |
    while IFS=$'\x1f' read -r full subj date; do
        grep -qx "$full" <<<"$processed" && continue
        printf '%s\t%s\t%s\n' "$full" "$date" "$subj"
    done | awk -v n="$n" 'NR<=n'   # head는 SIGPIPE+pipefail로 비정상 종료 유발
}

# ---------- signals ----------

cmd_signals() {
    local hash="$1"
    git rev-parse --verify -q "$hash^{commit}" >/dev/null || { echo "잘못된 해시: $hash" >&2; exit 1; }

    echo "=== COMMIT ==="
    git log -1 --date=format:%Y-%m-%d --pretty=format:'%H%n%s%n%ad%n' "$hash"

    echo "=== SIZE ==="
    git show --stat --format= "$hash" | tail -1

    echo "=== MERGE-TREE (cherry-pick 충돌 예측) ==="
    if git merge-tree --write-tree --merge-base="$hash^" "$BASE_BRANCH" "$hash" >/tmp/mt.$$ 2>&1; then
        echo "CLEAN"
    else
        echo "CONFLICT"
        # 충돌 파일 추출 — stage 행(<mode> <oid> <stage>\t<path>)만 사용한다.
        # 정보성 메시지(Auto-merging 등)를 섞으면 충돌 아닌 파일이 충돌로 보인다.
        grep -E '^[0-9]{6} [0-9a-f]{40} [123]	' /tmp/mt.$$ | cut -f2 | sort -u | awk "NR<=20" || true
    fi
    rm -f /tmp/mt.$$

    local paths
    paths="$(git diff-tree --no-commit-id --name-only -r "$hash")"

    echo "=== MISSING PATHS (HEAD에 없는 터치 경로) ==="
    while IFS= read -r p; do
        git cat-file -e "$BASE_BRANCH:$p" 2>/dev/null || echo "$p"
    done <<<"$paths" | awk "NR<=20"

    echo "=== PROTECTED PATHS (포크 보호 경로 접촉 — 리브랜드 자산·i18n·앱 식별자·배포) ==="
    grep -E '^(assets/base/i18n/|assets/base/release/|android/app/src/main/res/|android/app/build\.gradle|android/app/google-services\.json|ios/Mattermost/Info\.plist|ios/Mattermost/Images\.xcassets/|ios/MattermostShare/Info\.plist|ios/NotificationService/Info\.plist|ios/[^/]+/[^/]+\.entitlements|ios/Mattermost\.xcodeproj/project\.pbxproj|fastlane/|\.github/workflows/|specs/|\.claude/|\.specify/|\.agents/)' <<<"$paths" | awk "NR<=20" || echo "(없음)"

    echo "=== RISK PATHS (정밀 레인 트리거 — DB 스키마·네이티브 모듈·의존성·패치) ==="
    grep -E '^(app/database/migration/|app/database/schema/|libraries/@mattermost/|patches/|package\.json|package-lock\.json|ios/Podfile|android/build\.gradle|android/gradle)' <<<"$paths" | awk "NR<=20" || echo "(없음)"

    echo "=== FORK HISTORY (터치 경로의 우리 자체 커밋 — 우리가 이 영역을 바꿨는가) ==="
    # 포크 자체 커밋 = main에만 있는 커밋 (upstream에 없는 것)
    local -a path_arr=()
    while IFS= read -r p; do [[ -n "$p" ]] && path_arr+=("$p"); done <<<"$paths"
    if [[ ${#path_arr[@]} -gt 0 ]]; then
        git log --oneline "$UPSTREAM_BRANCH..$BASE_BRANCH" --max-count=10 -- "${path_arr[@]}" 2>/dev/null || true
    fi
}

# ---------- exclude / to-spec ----------

append_appendix() {
    local title="$1" hash="$2" info="$3" extra_col="${4:-비고}"
    local full subj
    full="$(git rev-parse "$hash^{commit}")"
    subj="$(git log -1 --pretty=format:'%s' "$full")"
    subj="${subj//|/\\|}"; subj="${subj//[/\\[}"; subj="${subj//]/\\]}"
    info="${info//|/\\|}"
    # 섹션 마지막 표 행 뒤에 추가. 섹션이 아직 없으면(신규 카테고리 최초 사용) 파일 끝에 새로 만든다.
    local py=python3
    "$py" -c '' >/dev/null 2>&1 || py=python
    "$py" - "$LEDGER" "$title" "$extra_col" "| ${full:0:8} | [$subj]($UPSTREAM_URL/commit/$full) | $info |" <<'EOF'
import sys
path, title, extra_col, row = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
lines = open(path, encoding="utf-8").read().splitlines()
out, in_sec, inserted = [], False, False
for l in lines:
    if l.startswith("## "):
        if in_sec and not inserted:
            out.append(row); inserted = True
        in_sec = l == f"## {title}"
    out.append(l)
if in_sec and not inserted:
    out.append(row); inserted = True
if not inserted:
    # 섹션이 파일에 아예 없었던 경우 — 새 섹션을 끝에 생성
    if out and out[-1] != "":
        out.append("")
    out += [f"## {title}", "", f"| 커밋 해시 | 커밋 제목 | {extra_col} |", "|---|---|---|", row]
open(path, "w", encoding="utf-8").write("\n".join(out) + "\n")
EOF
}

cmd_exclude() { append_appendix "제외된 커밋" "$1" "$2" "사유"; cmd_update; }
cmd_tospec()  { append_appendix "spec 전환 커밋" "$1" "$2" "spec"; cmd_update; }

# ---------- 진입점 ----------

case "${1:-}" in
    update)  cmd_update ;;
    status)  cmd_status ;;
    next)    cmd_next "${2:-1}" ;;
    signals) [[ $# -ge 2 ]] || { echo "signals <hash>" >&2; exit 1; }; cmd_signals "$2" ;;
    exclude) [[ $# -ge 3 ]] || { echo "exclude <hash> <사유>" >&2; exit 1; }; cmd_exclude "$2" "$3" ;;
    to-spec) [[ $# -ge 3 ]] || { echo "to-spec <hash> <specID>" >&2; exit 1; }; cmd_tospec "$2" "$3" ;;
    *) sed -n '2,14p' "$0"; exit 1 ;;
esac
