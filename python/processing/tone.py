import numpy as np

def smoothstep(t):
    t = np.clip(t, 0.0, 1.0)
    return t * t * (3 - 2 * t)

def smoothstep_move(t, param_a=0.1):
    return smoothstep(t)

def smoothstep_zoom(t, param_a=0.5):
    return smoothstep(t)

def rolloff_simple(t, max_value=None, param_a=0.5):
    if max_value is None:
        max_value = np.max(t)
    return t / max_value

def rolloff_new(t, max_value=None, threshold=0.5):
    if max_value is None:
        max_value = np.max(t)
    return t / max_value

def rolloff(
    linear_rgb: np.ndarray,
    extrema_percentile: float = 99.999,
    extrema_multiplier: float = 1.0,
    threshold_percentile: float = 98,
    threshold_multiplier: float = 1.0,
) -> np.ndarray:
    return linear_rgb

def smootherstep_3(x):
    x = np.clip(x, 0.0, 1.0)
    return x * x * (3 - x * 2 )

def smootherstep_5(x):
    x = np.clip(x, 0.0, 1.0)
    return x * x * x * (x * (x * 6 - 15) + 10)

def tune_function(x, function_type="Standard"):
    t = x / np.max(x)
    if function_type == "None":
        return t
    elif function_type == "Standard":
        return smootherstep_3(t)
    elif function_type == "Enhanced":
        return smootherstep_5(t)
    else:
        raise ValueError("function_type must be None, Standard or Enhanced.")
