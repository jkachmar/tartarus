#!/usr/bin/env python3
"""Update sources.json with hashes for polytoken version(s).

Usage:
    ./update.py
        Update `sources.json` with the latest entries from both the
        "latest" and "stable" release channels.

    ./update.py <version>
        Pin an explicit polytoken version in `sources.json` without
        touching `latest` / `stable` entries.
"""
from __future__ import annotations

import base64
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Deliberately resolved against the current working directory, not
# `__file__`: nixpkgs-style updateScript runners (e.g. `nix-update
# --flake -u`) execute this script from an immutable copy elsewhere (a
# Nix store path) while setting `cwd` to the real, writable source tree.
SOURCES_FILE = Path.cwd() / "sources.json"
BASE_URL = "https://dl.polytoken.dev"
VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")

# Mapping from nix platform to polytoken platform/SHA256SUMS filename
PLATFORMS = {
    "x86_64-linux": ("linux-amd64", "linux"),
    "aarch64-linux": ("linux-arm64", "linux"),
    "x86_64-darwin": ("macos-amd64", "macos"),
    "aarch64-darwin": ("macos-arm64", "macos"),
}

_CURL_ARGS = [
    "curl",
    "--proto", "=https",
    "--tlsv1.2",
    "--retry", "3",
    "--retry-delay", "1",
    "-sSfL",
]


def fetch(url: str) -> str:
    """Fetch a URL's body as text via curl."""
    if not url.startswith("https://"):
        sys.exit(f"error: refusing to fetch non-https URL: {url}")

    result = subprocess.run([*_CURL_ARGS, url], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"error: failed to fetch {url}: {result.stderr.strip()}")
    return result.stdout


def hex_to_sri(hex_digest: str) -> str:
    return "sha256-" + base64.b64encode(bytes.fromhex(hex_digest)).decode()


def fetch_version_entry(version: str) -> dict:
    """Return `{nix_platform: {platform, hash}}` for `version`."""
    checksums_by_family: dict[str, str] = {}
    entry = {}

    for nix_platform, (platform, family) in PLATFORMS.items():
        if family not in checksums_by_family:
            url = f"{BASE_URL}/{version}/SHA256SUMS.{family}"
            print(f"fetching {url} ...", file=sys.stderr)
            checksums_by_family[family] = fetch(url)

        want = f"{platform}/polytoken.zip"
        hex_digest = next(
            (
                parts[0]
                for line in checksums_by_family[family].splitlines()
                if (parts := line.split()) and len(parts) == 2 and parts[1] == want
            ),
            None,
        )
        if hex_digest is None:
            sys.exit(
                f"error: no checksum found for {want} in "
                f"SHA256SUMS.{family} (version {version})"
            )

        entry[nix_platform] = {"platform": platform, "hash": hex_to_sri(hex_digest)}

    return entry


def load_sources() -> dict:
    if SOURCES_FILE.exists():
        return json.loads(SOURCES_FILE.read_text())
    return {"latest": None, "stable": None, "versions": {}}


def save_sources(sources: dict) -> None:
    tmp_file = SOURCES_FILE.with_name(SOURCES_FILE.name + ".tmp")
    tmp_file.write_text(json.dumps(sources, indent=2) + "\n")
    tmp_file.replace(SOURCES_FILE)


def resolve_channels() -> tuple[str, str]:
    url = f"{BASE_URL}/channels.json"
    print(f"resolving channels from {url} ...", file=sys.stderr)
    channels = json.loads(fetch(url))["channels"]
    return channels["latest"], channels["stable"]


def check_version(version: str) -> str:
    if not VERSION_RE.match(version):
        sys.exit(f"error: expected a plain semver version, got '{version}'")
    return version


def main() -> None:
    args = sys.argv[1:]
    if len(args) > 1:
        sys.exit(f"Usage: {Path(sys.argv[0]).name} [version]")

    if shutil.which("curl") is None:
        sys.exit("error: required command 'curl' not found")

    sources = load_sources()

    if args:
        version = check_version(args[0])
        sources["versions"][version] = fetch_version_entry(version)
        print(f"updated {SOURCES_FILE}: added version {version}", file=sys.stderr)
    else:
        latest, stable = (check_version(v) for v in resolve_channels())
        for version in {latest, stable}:
            sources["versions"][version] = fetch_version_entry(version)

        sources["latest"] = latest
        sources["stable"] = stable
        sources["versions"] = {
            version: entry
            for version, entry in sources["versions"].items()
            if version in (latest, stable)
        }
        print(
            f"updated {SOURCES_FILE}: latest={latest} stable={stable} ",
            file=sys.stderr,
        )

    save_sources(sources)


if __name__ == "__main__":
    main()
