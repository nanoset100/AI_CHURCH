"""
Android 상태바/네비게이션바 제거 + iOS 스타일 상태바 추가
"""
from PIL import Image, ImageDraw, ImageFont
import os
import glob

# 설정
TOP_CROP = 96      # Android 상태바 높이 (픽셀)
BOTTOM_CROP = 126  # Android 하단 네비게이션바 높이 (픽셀)
IOS_STATUS_HEIGHT = 96  # iOS 상태바 높이
STATUS_BG_COLOR = (74, 144, 226)  # 앱 Primary 색상 #4A90E2

def add_ios_status_bar(img, status_height=96, bg_color=(74, 144, 226)):
    """iOS 스타일 상태바 추가"""
    w, h = img.size
    new_img = Image.new('RGB', (w, h + status_height), bg_color)

    draw = ImageDraw.Draw(new_img)

    # 상태바 텍스트 (간단하게)
    try:
        # 폰트 없으면 기본 폰트 사용
        font = ImageFont.load_default()
    except:
        font = None

    # 시간 표시
    draw.text((60, 30), "9:41", fill=(255, 255, 255), font=font)
    # 배터리/신호 표시 (간단한 사각형으로)
    draw.rectangle([w-140, 28, w-100, 60], fill=(255, 255, 255))  # 배터리
    draw.rectangle([w-90, 35, w-65, 55], fill=(255, 255, 255))    # 신호
    draw.rectangle([w-55, 35, w-30, 55], fill=(255, 255, 255))    # 와이파이

    # 원본 이미지 붙이기
    new_img.paste(img, (0, status_height))
    return new_img

def process_screenshot(input_path, output_path):
    img = Image.open(input_path)
    w, h = img.size

    # Android 상태바/네비게이션바 크롭
    cropped = img.crop((0, TOP_CROP, w, h - BOTTOM_CROP))

    # iOS 상태바 추가
    result = add_ios_status_bar(cropped, IOS_STATUS_HEIGHT, STATUS_BG_COLOR)

    # 원본 크기로 리사이즈
    result = result.resize((w, h), Image.LANCZOS)

    result.save(output_path, 'PNG')
    print(f"  처리 완료: {os.path.basename(output_path)} ({w}x{h})")

# 모든 폴더 처리
folders = [
    'assets/store_screenshots/iphone_65',
    'assets/store_screenshots/iphone_67',
    'assets/store_screenshots/ipad_13',
]

for folder in folders:
    if not os.path.exists(folder):
        print(f"폴더 없음: {folder}")
        continue

    print(f"\n처리 중: {folder}")
    pngs = glob.glob(f"{folder}/*.png")

    for png in sorted(pngs):
        process_screenshot(png, png)  # 원본 덮어쓰기

print("\n완료!")
