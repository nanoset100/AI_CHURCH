import os
from PIL import Image

icon_path = r"m:\MyProject777\test009AICHURCH\assets\icon\app_icon.png"
output_dir = r"m:\MyProject777\test009AICHURCH\assets\icon"

print(f"Processing Play Store assets from {icon_path}...")

try:
    with Image.open(icon_path) as img:
        # 1. 앱 아이콘 (512x512)
        icon_512 = img.resize((512, 512), Image.Resampling.LANCZOS)
        icon_512.save(os.path.join(output_dir, "play_store_512.png"))
        print("Generated: play_store_512.png (512x512)")

        # 2. 그래픽 이미지 (1024x500)
        # 비율이 다르므로 캔버스를 먼저 만들고 아이콘을 중앙에 배치하거나 리사이징
        feature_graphic = Image.new("RGB", (1024, 500), (255, 255, 255)) # 흰색 배경
        
        # 아이콘을 높이(500)에 맞춰 리사이징
        logo_height = 400
        aspect_ratio = img.width / img.height
        logo_width = int(logo_height * aspect_ratio)
        img_resized = img.resize((logo_width, logo_height), Image.Resampling.LANCZOS)
        
        # 중앙 배치
        offset = ((1024 - logo_width) // 2, (500 - logo_height) // 2)
        feature_graphic.paste(img_resized, offset, img_resized if img_resized.mode == 'RGBA' else None)
        
        feature_graphic.save(os.path.join(output_dir, "feature_graphic_1024x500.png"))
        print("Generated: feature_graphic_1024x500.png (1024x500)")

except Exception as e:
    print(f"Error processing assets: {e}")

print("Done.")
