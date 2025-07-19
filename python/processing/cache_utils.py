import hashlib
from pathlib import Path
import pandas as pd
import numpy as np
from core.calibration import RollCalibrationProfile
from core.recipe import TechnicalRecipe

def generate_recipe_key(recipe: TechnicalRecipe) -> str:
    recipe_string = repr(recipe)
    hasher = hashlib.sha256()
    hasher.update(recipe_string.encode('utf-8'))
    return hasher.hexdigest()[:16]

def save_profile_to_csv(profile: RollCalibrationProfile, file_path: Path):
    pass

def load_profile_from_csv(file_path: Path) -> RollCalibrationProfile | None:
    return None
