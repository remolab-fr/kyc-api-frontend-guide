#!/usr/bin/env python3
"""Stamp generated mdBook HTML with build metadata."""

from __future__ import annotations

import argparse
import html
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--book-dir", default="book")
    parser.add_argument("--timestamp", required=True)
    parser.add_argument("--commit", required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    book_dir = Path(args.book_dir)
    if not book_dir.is_dir():
        raise SystemExit(f"book directory does not exist: {book_dir}")

    replacements = {
        "__GUIDE_BUILD_TIMESTAMP__": html.escape(args.timestamp),
        "__GUIDE_BUILD_COMMIT__": html.escape(args.commit),
    }

    for html_file in book_dir.rglob("*.html"):
        content = html_file.read_text(encoding="utf-8")
        stamped = content
        for needle, value in replacements.items():
            stamped = stamped.replace(needle, value)
        if stamped != content:
            html_file.write_text(stamped, encoding="utf-8")

    (book_dir / "build-info.json").write_text(
        json.dumps(
            {
                "published_at": args.timestamp,
                "commit": args.commit,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
