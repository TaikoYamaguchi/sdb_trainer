import os
from PIL import Image

def image_resize(filepath):
    print(filepath)
    img = Image.open(filepath)
    print(img)
    print(img.size)
    width, height = img.size
    if (width > 900):
        new_height = height * 900 / width
        img.thumbnail((900, int(new_height)))
        print(img.size)
        print(filepath)
        img.save(filepath)
        print("successsss")
        img.close()


