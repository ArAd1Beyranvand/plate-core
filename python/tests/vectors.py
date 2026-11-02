import json
from pathlib import Path

_ROOT = Path(__file__).resolve().parents[2] / "vectors"


def load_vectors(rel: str) -> list[dict]:
    """Loads `ports/vectors/<rel>` (e.g. `core/alphabet.json`) and returns its cases."""
    return json.loads((_ROOT / rel).read_text(encoding="utf8"))["cases"]
