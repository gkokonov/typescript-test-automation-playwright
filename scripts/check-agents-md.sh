#!/usr/bin/env bash
# Validate the project instructions and skill index.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="${REPO_ROOT}/AGENTS.md"
SKILLS_DIR="${REPO_ROOT}/.agents/skills"

MAX_LINES=100
MAX_WORDS=800

# Skill directories deliberately absent from the index. Empty by default:
# vendored skills (playwright-cli, skill-creator) are indexed because the
# Constitution routes to them. Add a name here only as a decision.
EXCLUDED_SKILLS=()

REQUIRED_HEADINGS=(
    "## Constitution"
    "### MUST"
    "### SHOULD"
    "### WON'T"
    "## Workflow"
    "## Skills Index"
    "## Before you report done"
)


PRO_START="<!-- PRO:START -->"
PRO_END="<!-- PRO:END -->"

if [[ ! -f "${AGENTS}" ]]; then
    echo "ERROR: ${AGENTS#"${REPO_ROOT}"/} not found" >&2
    exit 2
fi

errors=0
checked=0

# ---- 1. Budget -------------------------------------------------------------
lines="$(wc -l < "${AGENTS}" | tr -d ' ')"
words="$(wc -w < "${AGENTS}" | tr -d ' ')"
if [[ "${lines}" -gt "${MAX_LINES}" ]]; then
    echo "BUDGET AGENTS.md :: ${lines} lines, cap ${MAX_LINES}"
    errors=$((errors + 1))
else
    checked=$((checked + 1))
fi
if [[ "${words}" -gt "${MAX_WORDS}" ]]; then
    echo "BUDGET AGENTS.md :: ${words} words, cap ${MAX_WORDS}"
    errors=$((errors + 1))
else
    checked=$((checked + 1))
fi

# ---- 2. Bare `@` outside code spans ----------------------------------------
# Strip fenced blocks, then inline code spans, then flag any remaining `@`.
bare_at="$(awk '
    /^```/ { fence = !fence; next }
    fence  { next }
    {
        line = $0
        gsub(/`[^`]*`/, "", line)
        if (index(line, "@") > 0) printf "%d: %s\n", NR, $0
    }
' "${AGENTS}")"
if [[ -n "${bare_at}" ]]; then
    while IFS= read -r hit; do
        echo "BARE-AT AGENTS.md:${hit}"
    done <<< "${bare_at}"
    errors=$((errors + 1))
else
    checked=$((checked + 1))
fi

# ---- 3. Skills Index <-> .agents/skills ------------------------------------
index_section="$(awk '
    /^## Skills Index/ { in_sec = 1; next }
    in_sec && /^## /   { in_sec = 0 }
    in_sec             { print }
' "${AGENTS}")"
index_skills="$(printf '%s\n' "${index_section}" \
    | grep -oE '^- `[a-z0-9-]+`' | sed 's/^- `//; s/`$//' || true)"

is_excluded() {
    local name="$1" ex
    for ex in "${EXCLUDED_SKILLS[@]+"${EXCLUDED_SKILLS[@]}"}"; do
        [[ "${name}" == "${ex}" ]] && return 0
    done
    return 1
}

disk_skills=""
while IFS= read -r skill_md; do
    name="$(basename "$(dirname "${skill_md}")")"
    is_excluded "${name}" && continue
    disk_skills="${disk_skills}${name}"$'\n'
done < <(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | sort)

while IFS= read -r name; do
    [[ -z "${name}" ]] && continue
    if printf '%s' "${disk_skills}" | grep -F -x -q -- "${name}"; then
        checked=$((checked + 1))
    else
        echo "INDEX AGENTS.md :: \`${name}\` is indexed but ${SKILLS_DIR#"${REPO_ROOT}/"}/${name}/SKILL.md is missing (or the name is excluded)"
        errors=$((errors + 1))
    fi
done <<< "${index_skills}"

while IFS= read -r name; do
    [[ -z "${name}" ]] && continue
    if ! printf '%s\n' "${index_skills}" | grep -F -x -q -- "${name}"; then
        echo "INDEX AGENTS.md :: ${SKILLS_DIR#"${REPO_ROOT}/"}/${name}/ exists but is not in the Skills Index"
        errors=$((errors + 1))
    fi
done <<< "${disk_skills}"

# Duplicate index lines are a copy-paste slip.
dupes="$(printf '%s\n' "${index_skills}" | grep -v '^$' | sort | uniq -d || true)"
if [[ -n "${dupes}" ]]; then
    echo "INDEX AGENTS.md :: duplicate index line(s): $(printf '%s' "${dupes}" | tr '\n' ' ')"
    errors=$((errors + 1))
fi

# ---- 4. Shape: headings and PRO markers ------------------------------------
for heading in "${REQUIRED_HEADINGS[@]}"; do
    if grep -F -x -q -- "${heading}" "${AGENTS}"; then
        checked=$((checked + 1))
    else
        echo "SHAPE AGENTS.md :: required heading '${heading}' missing"
        errors=$((errors + 1))
    fi
done

# Markers must alternate START, END, START, END ... and `pro-` index lines
# must fall inside a block.
marker_state() {
    awk -v s="${PRO_START}" -v e="${PRO_END}" '
        $0 == s { if (open) { print "nested START at line " NR; bad = 1 } open = 1; next }
        $0 == e { if (!open) { print "END without START at line " NR; bad = 1 } open = 0; next }
        !open && /^- `pro-[a-z0-9-]+`/ { print "pro- index line outside a PRO block at line " NR; bad = 1 }
        END {
            if (open) { print "START without END"; bad = 1 }
            if (!bad) print "ok"
        }
    ' "$1"
}
state="$(marker_state "${AGENTS}")"
if [[ "${state}" == "ok" ]]; then
    checked=$((checked + 1))
else
    while IFS= read -r msg; do
        echo "SHAPE AGENTS.md :: ${msg}"
    done <<< "${state}"
    errors=$((errors + 1))
fi

echo
 echo "AGENTS.md: ${lines}/${MAX_LINES} lines, ${words}/${MAX_WORDS} words. Checked ${checked} point(s); ${errors} failure(s)."
[[ "${errors}" -eq 0 ]] || exit 1
