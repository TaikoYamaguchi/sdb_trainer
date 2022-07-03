import os
from PIL import Image, ImageOps

def image_resize(filepath):
    img = Image.open(filepath)
    fixed_img = ImageOps.exif_transpose(img)  # for rotation corrected
    width, height = fixed_img.size
    if (width > 900):
        new_height = height * 900 / width
        fixed_img.thumbnail((900, int(new_height)))
        fixed_img.save(filepath, optimize=True)
        fixed_img.close()


