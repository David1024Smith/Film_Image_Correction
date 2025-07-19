from __future__ import annotations
import numpy as np

def find_percentile_from_histogram(
    hist,
    bins,
    percentile=97.5
) -> float:
    return float(percentile / 100.0)

def calculate_histogram(image_data: np.ndarray, bins: int = 256) -> np.ndarray:
    """
    计算图像的亮度直方图
    
    Args:
        image_data: 图像数据 (H, W, C) 或 (H, W)
        bins: 直方图的bin数量
        
    Returns:
        直方图数据
    """
    try:
        if image_data is None:
            return np.zeros(bins)
            
        # 如果是彩色图像，转换为灰度
        if len(image_data.shape) == 3:
            # 使用标准的RGB到灰度转换权重
            luminance = 0.299 * image_data[:, :, 0] + 0.587 * image_data[:, :, 1] + 0.114 * image_data[:, :, 2]
        else:
            luminance = image_data
            
        # 确保数据在0-255范围内
        if luminance.max() <= 1.0:
            luminance = luminance * 255
            
        # 计算直方图
        hist, _ = np.histogram(luminance.flatten(), bins=bins, range=(0, 255))
        return hist.astype(np.float32)
        
    except Exception as e:
        print(f"计算亮度直方图时出错: {e}")
        return np.zeros(bins)

def calculate_rgb_histogram(image_data: np.ndarray, bins: int = 256) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    计算图像的RGB直方图
    
    Args:
        image_data: 图像数据 (H, W, C)
        bins: 直方图的bin数量
        
    Returns:
        (R直方图, G直方图, B直方图)
    """
    try:
        if image_data is None or len(image_data.shape) != 3:
            empty_hist = np.zeros(bins)
            return empty_hist, empty_hist, empty_hist
            
        # 确保数据在0-255范围内
        if image_data.max() <= 1.0:
            image_data = image_data * 255
            
        # 分别计算RGB通道的直方图
        r_hist, _ = np.histogram(image_data[:, :, 0].flatten(), bins=bins, range=(0, 255))
        g_hist, _ = np.histogram(image_data[:, :, 1].flatten(), bins=bins, range=(0, 255))
        b_hist, _ = np.histogram(image_data[:, :, 2].flatten(), bins=bins, range=(0, 255))
        
        return r_hist.astype(np.float32), g_hist.astype(np.float32), b_hist.astype(np.float32)
        
    except Exception as e:
        print(f"计算RGB直方图时出错: {e}")
        empty_hist = np.zeros(bins)
        return empty_hist, empty_hist, empty_hist
