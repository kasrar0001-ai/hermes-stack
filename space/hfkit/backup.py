#!/usr/bin/env python3
"""Tar /opt/data and upload to the private HF dataset repo.

Uploads:
  - latest.tar.gz            (always overwritten)
  - hourly-YYYYmmdd-HHMM.tar.gz  (kept for the last BACKUP_KEEP_HOURS hours)
"""
import os
import tarfile
import tempfile
import time
from datetime import datetime, timedelta, timezone

from huggingface_hub import HfApi

REPO = os.environ.get("BACKUP_REPO", "").strip()
TOKEN = os.environ.get("HF_TOKEN", "").strip()
KEEP_HOURS = int(os.environ.get("BACKUP_KEEP_HOURS", "72"))
SRC = "/opt/data"

if not REPO or not TOKEN:
    raise SystemExit("[backup] BACKUP_REPO / HF_TOKEN not set")

api = HfApi(token=TOKEN)

EXCLUDE_DIRS = {"__pycache__", "logs", "backups"}


def exclude_filter(tarinfo: tarfile.TarInfo) -> tarfile.TarInfo | None:
    parts = tarinfo.name.split("/")
    if any(p in EXCLUDE_DIRS for p in parts):
        return None
    if tarinfo.name.endswith((".pyc", ".pyo", ".tmp")):
        return None
    return tarinfo


tmp = tempfile.mktemp(prefix="backup-", suffix=".tar.gz")  # noqa: S306
with tarfile.open(tmp, "w:gz") as t:
    t.add(SRC, arcname=".", filter=exclude_filter)

size_mb = os.path.getsize(tmp) / 1e6
print(f"[backup] archive size: {size_mb:.1f} MB")

stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M")
base = {
    "path_or_fileobj": tmp,
    "repo_id": REPO,
    "repo_type": "dataset",
}

api.upload_file(**base, path_in_repo="latest.tar.gz",
                commit_message=f"backup {stamp}")
api.upload_file(**base, path_in_repo=f"hourly-{stamp}.tar.gz",
                commit_message=f"hourly backup {stamp}")

# prune old hourly snapshots
cutoff = datetime.now(timezone.utc) - timedelta(hours=KEEP_HOURS)
try:
    for f in api.list_repo_files(repo_id=REPO, repo_type="dataset"):
        if f.startswith("hourly-") and f.endswith(".tar.gz"):
            stamp_str = f[len("hourly-"):-len(".tar.gz")]
            try:
                dt = datetime.strptime(stamp_str, "%Y%m%d-%H%M").replace(tzinfo=timezone.utc)
            except ValueError:
                continue
            if dt < cutoff:
                api.delete_file(path_in_repo=f, repo_id=REPO, repo_type="dataset",
                                commit_message=f"prune {f}")
except Exception as e:  # noqa: BLE001
    print(f"[backup] prune skipped: {e}")

os.unlink(tmp)
print("[backup] done.")
