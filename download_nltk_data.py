#!/usr/bin/env python3
"""
Download required NLTK data packages into a user-writable directory,
using certifi's CA bundle to avoid SSL errors.

Usage:
  python download_nltk_data.py

Environment:
  - Uses $NLTK_DATA if set, else defaults to ~/nltk_data
  - Works inside a venv; ensure certifi is installed in the venv

Packages downloaded:
  - tokenizers: punkt
  - corpora: stopwords, wordnet
  - taggers: averaged_perceptron_tagger
"""
import os
import sys
import ssl
import certifi
import nltk
from pathlib import Path

REQUIRED_PACKAGES = [
    ("tokenizers", "punkt"),
    ("tokenizers", "punkt_tab"),  # Needed by newer NLTK versions
    ("corpora", "stopwords"),
    ("corpora", "wordnet"),
    ("taggers", "averaged_perceptron_tagger"),
    ("taggers", "averaged_perceptron_tagger_eng"),  # Newer tagger resource name
]

def ensure_nltk_data_dir() -> Path:
    base = os.environ.get("NLTK_DATA", str(Path.home() / "nltk_data"))
    base_path = Path(base)
    base_path.mkdir(parents=True, exist_ok=True)
    # Create subdirs to keep structure tidy
    for sub in ["tokenizers", "corpora", "taggers"]:
        (base_path / sub).mkdir(parents=True, exist_ok=True)
    return base_path

def configure_ssl_certifi():
    # Force NLTK downloader to use certifi CA bundle
    ssl._create_default_https_context = lambda *args, **kwargs: ssl.create_default_context(cafile=certifi.where())


def download_packages(base_path: Path) -> bool:
    ok = True
    print(f"NLTK data directory: {base_path}")
    for subdir, pkg in REQUIRED_PACKAGES:
        print(f"→ Downloading {pkg} ({subdir})…", end=" ")
        try:
            nltk.download(pkg, download_dir=str(base_path), quiet=False)
            # Verify presence
            resource_path = f"{subdir}/{pkg}"
            try:
                nltk.data.find(resource_path)
                print("✓")
            except LookupError:
                print("⚠ not found after download")
                ok = False
        except Exception as e:
            print(f"✗ error: {e}")
            ok = False
    return ok


def main():
    base_path = ensure_nltk_data_dir()
    configure_ssl_certifi()
    success = download_packages(base_path)
    print("\nSummary:")
    print(f"  NLTK_DATA={base_path}")
    print(f"  Success: {'YES' if success else 'PARTIAL/NO'}")
    if not success:
        print("\nIf downloads failed due to network/SSL, you can manually fetch ZIPs:")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/tokenizers/punkt.zip")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/tokenizers/punkt_tab.zip")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/stopwords.zip")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/wordnet.zip")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/taggers/averaged_perceptron_tagger.zip")
        print("  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/taggers/averaged_perceptron_tagger_eng.zip")
        print(f"Then unzip into {base_path}/<subdir> accordingly.")
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
