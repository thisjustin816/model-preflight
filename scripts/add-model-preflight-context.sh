#!/bin/sh
# Injects a model preflight check into every Claude Code, Codex, and Cowork turn.
#
# POSIX port of Add-ModelPreflightContext.ps1 for hosts without pwsh, such as Cowork and most macOS
# and Linux machines. The comment-based help in that script documents the behavior and the rules
# file contract; this port must emit the same additionalContext, which tests/Test-HookParity.ps1
# checks. Needs only sh, awk, sed, and find.
#
# Usage: pipe the hook's JSON input on stdin. An optional first argument names a rules file to read
# on its own, in place of the default resolution order.

set -u

# Without these the output is an empty context that still parses, so a missing tool would pass for a
# working hook. Exiting non-zero makes the tool report the hook as failed instead.
for required_tool in awk sed find head tr dirname cat; do
    if ! command -v "$required_tool" >/dev/null 2>&1; then
        echo "model-preflight: $required_tool not found on PATH" >&2
        exit 1
    fi
done

rules_arg=${1-}
plugin_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
nl='
'
tab=$(printf '\t')

# Extract one `- **Marker**: ...` bullet, joining wrapped continuation lines into one line. Matching
# is case-insensitive to agree with PowerShell's -match.
get_trigger_line() {
    awk -v marker="$2" '
        BEGIN { pattern = tolower("^[ \t]*-[ \t][*][*]" marker "[*][*]:") }
        { sub(/\r$/, "") }
        found == 0 && tolower($0) ~ pattern {
            text = $0
            sub(/^[ \t]*-[ \t]*/, "", text)
            found = 1
            next
        }
        found == 1 {
            if ($0 ~ /^[ \t]+[^ \t]/ && $0 !~ /^[ \t]*-[ \t]/) {
                line = $0
                gsub(/^[ \t]+|[ \t]+$/, "", line)
                text = text " " line
            }
            else {
                found = 2
            }
        }
        END { if (found) printf "%s", text }
    ' "$1"
}

# Return the body under a `## Heading` up to the next `##` heading or horizontal rule. A `###`
# subheading stays part of the body.
get_instruction_section() {
    awk -v heading="$2" '
        { sub(/\r$/, "") }
        state == 2 { next }
        state == 0 {
            if (tolower($0) ~ ("^##[ \t]+" tolower(heading) "[ \t]*$")) state = 1
            next
        }
        {
            if ($0 ~ /^##[ \t]/ || $0 ~ /^---[ \t]*$/) { state = 2; next }
            body = (count++ ? body "\n" : "") $0
        }
        END {
            if (state) {
                sub(/^[ \t\n]+/, "", body)
                sub(/[ \t\n]+$/, "", body)
                printf "%s", body
            }
        }
    ' "$1"
}

hook_input=$(cat)
session_id=$(
    printf '%s' "$hook_input" |
        sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
        head -n 1
)
if [ -n "$session_id" ]; then
    session_id=$(printf '%s' "$session_id" | tr -c 'A-Za-z0-9_-' '_')
else
    session_id=unknown
fi

state_dir="${TMPDIR:-/tmp}/model-preflight"
turn=1
if mkdir -p "$state_dir" 2>/dev/null; then
    counter_file="$state_dir/$session_id.count"
    if [ -f "$counter_file" ]; then
        last_turn=$(head -n 1 "$counter_file" 2>/dev/null)
        case $last_turn in
            '' | *[!0-9]*) turn=1 ;;
            *) turn=$((last_turn + 1)) ;;
        esac
    fi
    printf '%s\n' "$turn" >"$counter_file" 2>/dev/null || turn=1
    find "$state_dir" -name '*.count' -type f -mtime +7 -exec rm -f {} + 2>/dev/null
fi

if [ -n "$rules_arg" ]; then
    set -- "$rules_arg"
else
    set -- \
        "${MODEL_PREFLIGHT_RULES-}" \
        "$HOME/.agents/model-strategy.md" \
        "$HOME/.codex/AGENTS.md" \
        "$HOME/.claude/model-strategy.md" \
        "$plugin_root/skills/model-preflight/SKILL.md"
fi

candidate_list=''
escalate=''
downshift=''
recheck=''
tiers=''
pause=''
for candidate in "$@"; do
    [ -n "$candidate" ] || continue
    candidate_list="${candidate_list:+$candidate_list, }$candidate"
    [ -z "$recheck" ] || continue
    [ -f "$candidate" ] && [ -r "$candidate" ] || continue
    candidate_escalate=$(get_trigger_line "$candidate" 'Escalate')
    candidate_downshift=$(get_trigger_line "$candidate" 'Downshift')
    candidate_recheck=$(get_trigger_line "$candidate" 'Re-check')
    # All three or none, for the reason given at the same check in the PowerShell script.
    if [ -n "$candidate_escalate" ] && [ -n "$candidate_downshift" ] && [ -n "$candidate_recheck" ]; then
        escalate=$candidate_escalate
        downshift=$candidate_downshift
        recheck=$candidate_recheck
        tiers=$(get_instruction_section "$candidate" 'Tiers')
        pause=$(get_instruction_section "$candidate" 'Pause')
    fi
done

missing_note=''
if [ -z "$recheck" ]; then
    missing_note="$nl${nl}NOTE: no complete model strategy could be read from $candidate_list. A rules file has to \
carry all three of the Escalate, Downshift and Re-check bullets, and one carrying only some of them \
is skipped. The preflight is running without its trigger list. Tell the user, so the rules file \
gets restored or MODEL_PREFLIGHT_RULES is pointed somewhere valid."
fi

if [ $((turn % 5)) -eq 1 ]; then
    context='Before starting a new task, apply the model strategy below before any skill announcement, plan, or
tool call. A new task starts when a message introduces a goal, file, or scope not already in play.
Before your first tool call on a new task, state the verdict in one sentence in your reply: the
setting you are keeping or recommending, the single trigger closest to the task, and why it does or
does not apply. Silence is not a verdict. If a trigger applies, pause as described below.'
    [ -z "$escalate" ] ||
        context="$context$nl$nl$escalate Pause even if you are confident the current model can handle it."
    [ -z "$downshift" ] || context="$context$nl$nl$downshift"
    [ -z "$recheck" ] || context="$context$nl$nl$recheck"
    [ -z "$tiers" ] || context="$context$nl$nl## Tiers$nl$nl$tiers"
    [ -z "$pause" ] || context="$context$nl$nl## Pause$nl$nl$pause"
    context="$context$nl${nl}The check is not limited to the first action of a task. The Re-check bullet above names the moments
where a task has quietly become a different one. At each of them, run the check again and state the
verdict again, and if a trigger now matches, stop at the next safe boundary and pause before
continuing.$missing_note"
else
    context='Model preflight: if this message starts a new task (a goal, file, or scope not already in play), or a
Re-check moment has occurred since the last verdict, state the verdict in one sentence in your reply:
the setting you are keeping or recommending, the closest trigger, and why it does or does not apply.
Silence is not a verdict. If a trigger applies, deliver the mandatory pause exactly as the model
strategy specifies; it overrides autonomy and continuation instructions, auto mode included.'
    [ -z "$recheck" ] || context="$context$nl$nl$recheck"
    context="$context$missing_note"
fi

escaped=$(
    printf '%s' "$context" |
        sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$tab/\\\\t/g" |
        awk 'NR > 1 { printf "%s", "\\n" } { printf "%s", $0 }'
)
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$escaped"
