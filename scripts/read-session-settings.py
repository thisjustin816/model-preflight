#!/usr/bin/env python3
"""Read only picker metadata from hook input and its exact Codex transcript turn."""
import json
from pathlib import Path
import re
import sys

EFFORTS = {'none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max', 'ultra'}


def model_name(value):
    return value if isinstance(value, str) and re.fullmatch(r'[A-Za-z0-9._:-]{1,200}', value) else None


def effort_name(value):
    return value if isinstance(value, str) and value in EFFORTS else None


def read_settings(data):
    model = model_name(data.get('model'))
    effort = effort_name(data.get('reasoning_effort'))
    model_source = effort_source = 'hook input'
    path, session, turn = (data.get(k) for k in ('transcript_path', 'session_id', 'turn_id'))
    if not effort and all(isinstance(v, str) and v for v in (path, session, turn)):
        identity = None
        current = None
        try:
            with Path(path).open(encoding='utf-8') as transcript:
                for line in transcript:
                    try:
                        record = json.loads(line)
                    except (ValueError, TypeError):
                        continue
                    if not isinstance(record, dict) or not isinstance(record.get('payload'), dict):
                        continue
                    payload = record['payload']
                    if record.get('type') == 'session_meta':
                        identity = payload.get('id')
                    elif record.get('type') == 'turn_context' and payload.get('turn_id') == turn:
                        current = payload
            if identity == session and current:
                recorded_model = model_name(current.get('model'))
                if recorded_model and (not model or model == recorded_model):
                    if not model:
                        model, model_source = recorded_model, 'matching transcript turn'
                    effort = effort_name(current.get('effort'))
                    effort_source = 'matching transcript turn'
        except (OSError, UnicodeError, ValueError):
            pass
    model_line = f'Current model: {model} ({model_source}).' if model else 'Current model: unknown (not supplied by this hook invocation).'
    effort_line = f'Current reasoning effort: {effort} ({effort_source}).' if effort else 'Current reasoning effort: unknown (no matching current-turn metadata).'
    return model_line + '\n' + effort_line


if __name__ == '__main__':
    try:
        data = json.load(sys.stdin)
    except (ValueError, TypeError):
        data = {}
    print(read_settings(data if isinstance(data, dict) else {}))
