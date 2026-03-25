"""
정확한 크롭으로 Android 상태바/네비게이션바 완전 제거
"""
from PIL import Image
import os
import glob

# 정밀 분석 결과
TOP_CROP = 240    # Android 상태바 + 여백 (앱 파란 헤더 시작점)
BOTTOM_CROP = 241 # Android 하단 네비게이션바

def process_screenshot(input_path, output_path, target_w, target_h):
    img = Image.open(input_path)
    w, h = img.size

    # 비율로 크롭 값 조정 (iphone_65 기준으로 다른 사이즈 적용)
    ratio_w = w / 1242
    ratio_h = h / 2688

    top = int(TOP_CROP * ratio_h)
    bottom = int(BOTTOM_CROP * ratio_h)

    # 크롭
    cropped = img.crop((0, top, w, h - bottom))

    # 타겟 크기로 리사이즈
    result = cropped.resize((target_w, target_h), Image.LANCZOS)
    result.save(output_path, 'PNG')
    print(f"  Done: {os.path.basename(output_path)} ({w}x{h} -> {target_w}x{target_h}, crop top={top} bottom={bottom})")

# 폴더별 타겟 크기
configs = [
    ('assets/store_screenshots/iphone_65', 1242, 2688),
    ('assets/store_screenshots/iphone_67', 1290, 2796),
    ('assets/store_screenshots/ipad_13',   2048, 2732),
]

for folder, tw, th in configs:
    if not os.path.exists(folder):
        print(f"Skip: {folder}")
        continue
    print(f"\nProcessing: {folder}")
    for png in sorted(glob.glob(f"{folder}/*.png")):
        process_screenshot(png, png, tw, th)

print("\n완료!")
