#!/usr/bin/env python3
"""
Parse version metadata from YAML files and output tab-separated text.

Usage:
  Format 1 (dataset.yaml):
    python version_display.py -t dataset dataset.yaml
    python version_display.py -t dataset dataset.yaml -d doid,biosample

  Format 2 (config.yaml):
    python version_display.py -t pair biosample-bioproject/config.yaml
    python version_display.py -t pair glytoucan-uniprot/config.yaml
"""

import argparse
import subprocess
import sys
from pathlib import Path

import yaml


class CommandError(Exception):
    """Raised when a shell command fails or produces no output."""


def run_command(cmd: str) -> str:
    """
    Execute a shell command and return its stdout as a stripped string.
    Raises CommandError if the command exits with a non-zero status or
    produces no output.
    """
    result = subprocess.run(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        stderr_msg = result.stderr.strip()
        raise CommandError(
            f"Command failed (exit {result.returncode}): {cmd}"
            + (f"\n  stderr: {stderr_msg}" if stderr_msg else "")
        )
    output = result.stdout.strip()
    if not output:
        raise CommandError(f"Command produced no output: {cmd}")
    return output


def resolve_display(display: str, method: dict) -> str:
    """
    Run each command in *method* and substitute the results into *display*.
    The display string uses {variable_name} placeholders that correspond to
    keys in *method*.
    Raises CommandError if any command fails or returns an empty string.
    """
    values = {}
    for key, cmd in method.items():
        values[key] = run_command(cmd)  # propagates CommandError on failure
    return display.format_map(values)


def process_dataset(yaml_path: Path, filter_names: set | None) -> None:
    """
    Process Format 1 (dataset.yaml) and write TSV rows to stdout.

    Each top-level key is a dataset name.  If *filter_names* is given, only
    those datasets are processed.  On a CommandError the dataset is skipped
    and the error is written to stderr.
    """
    with yaml_path.open(encoding="utf-8") as f:
        data = yaml.safe_load(f)

    for name, body in data.items():
        # Apply optional dataset filter
        if filter_names is not None and name not in filter_names:
            continue

        version = (body or {}).get("version") if body else None
        if not version:
            print(f"{name}\t")
            continue

        method = version.get("method", {})
        display = version.get("display", "")
        try:
            display_str = resolve_display(display, method)
        except CommandError as exc:
            print(f"[dataset={name}] {exc}", file=sys.stderr)
            continue  # skip this dataset, continue with the next one

        print(f"{name}\t{display_str}")


def process_pair(yaml_path: Path) -> None:
    """
    Process Format 2 (config.yaml) and write TSV rows to stdout.

    Format 2-a: top-level is a mapping  -> single row keyed by directory name.
    Format 2-b: top-level is a sequence -> one row per list item, key is
                "<directory>-<link.forward>".

    On a CommandError the entire run is aborted and the error is written to
    stderr before exiting with status 1.
    """
    dir_name = yaml_path.parent.name

    with yaml_path.open(encoding="utf-8") as f:
        data = yaml.safe_load(f)

    if isinstance(data, list):
        # Format 2-b: top-level is a list
        items = []
        for item in data:
            link = item.get("link", {})
            forward = link.get("forward", "")
            key = f"{dir_name}-{forward}" if forward else dir_name

            version = item.get("version")
            if not version:
                items.append((key, ""))
                continue

            method = version.get("method", {})
            display = version.get("display", "")
            try:
                display_str = resolve_display(display, method)
            except CommandError as exc:
                print(f"[pair={key}] {exc}", file=sys.stderr)
                sys.exit(1)

            items.append((key, display_str))

    else:
        # Format 2-a: top-level is a mapping
        items = []
        version = data.get("version")
        if not version:
            items.append((dir_name, ""))
        else:
            method = version.get("method", {})
            display = version.get("display", "")
            try:
                display_str = resolve_display(display, method)
            except CommandError as exc:
                print(f"[pair={dir_name}] {exc}", file=sys.stderr)
                sys.exit(1)
            items.append((dir_name, display_str))

    for key, display_str in items:
        print(f"{key}\t{display_str}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate version display strings from YAML and output as TSV."
    )
    parser.add_argument(
        "-t", "--type",
        required=True,
        choices=["dataset", "pair"],
        help="YAML format type: 'dataset' for Format 1, 'pair' for Format 2",
    )
    parser.add_argument(
        "-d", "--dataset",
        default=None,
        help=(
            "Comma-separated list of dataset names to process (Format 1 only). "
            "Example: -d doid,biosample"
        ),
    )
    parser.add_argument(
        "yaml_file",
        help="Path to the input YAML file",
    )
    args = parser.parse_args()

    yaml_path = Path(args.yaml_file)
    if not yaml_path.exists():
        print(f"Error: file not found: {yaml_path}", file=sys.stderr)
        sys.exit(1)

    # Parse the optional dataset filter
    filter_names = None
    if args.dataset:
        if args.type != "dataset":
            print(
                "Warning: --dataset is ignored when --type is not 'dataset'",
                file=sys.stderr,
            )
        else:
            filter_names = {name.strip() for name in args.dataset.split(",")}

    if args.type == "dataset":
        process_dataset(yaml_path, filter_names)
    else:
        process_pair(yaml_path)


if __name__ == "__main__":
    main()
