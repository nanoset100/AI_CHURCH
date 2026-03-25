"""
Android 상태바/네비게이션바 완전 제거 (OS 크롬 없이 순수 앱 화면만)
"""
from PIL import Image
import os
import glob

# 크롭 설정 - 더 공격적으로
TOP_CROP = 130     # Android 상태바 완전 제거
BOTTOM_CROP = 150  # Android 하단 네비게이션바 완전 제거

def process_screenshot(input_path, output_path):
    img = Image.open(input_path)
    w, h = img.size

    # Android 상태바/네비게이션바 크롭 제거
    cropped = img.crop((0, TOP_CROP, w, h - BOTTOM_CROP))

    # 원본 크기로 리사이즈 (OS 크롬 없이 앱 화면만 확대)
    result = cropped.resize((w, h), Image.LANCZOS)

    result.save(output_path, 'PNG')
    print(f"  Done: {os.path.basename(output_path)} ({w}x{h})")

# 모든 폴더 처리
folders = [
    'assets/store_screenshots/iphone_65',
    'assets/store_screenshots/iphone_67',
    'assets/store_screenshots/ipad_13',
]

for folder in folders:
    if not os.path.exists(folder):
        print(f"Skip: {folder}")
        continue
    print(f"\nProcessing: {folder}")
    pngs = sorted(glob.glob(f"{folder}/*.png"))
    for png in pngs:
        process_screenshot(png, png)

print("\n완료!")
