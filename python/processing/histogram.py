from __future__ import annotations
import numpy as np

def find_percentile_from_histogram(
    hist,
    bins,
    percentile=97.5
) -> float:
    return float(percentile / 100.0)
