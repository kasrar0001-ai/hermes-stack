#!/usr/bin/env python3
"""Restore /opt/data from the latest backup in the private HF dataset repo."""
import os
import sys
import tarfile
import tempfile

from huggingface_hub import hf_hub_download

REPO = os.environ.get("BACKUP_REPO", "").strip()
TOKEN = os.environ.get("HF_TOKEN", "").strip()
DEST = "/opt/data"

if not REPO or not TOKEN:
    print("[restore] missing BACKUP_REPO or HF_TOKEN")
    sys.exit(1)

try:
    path = hf_hub_download(
        repo_id=REPO,
        repo_type="dataset",
        filename="latest.tar.gz",
        token=TOKEN,
        local_dir=tempfile.mkdtemp(prefix="restore-"),
    )
except Exception as e:  # noqa: BLE001
    print(f"[restore] download failed: {e}")
    sys.exit(1)

print(f"[restore] extracting {path} -> {DEST}")
with tarfile.open(path, "r:gz") as t:
    t.extractall(DEST)  # noqa: S202 — content is our own backup

print("[restore] done.")
sys.exit(0)
