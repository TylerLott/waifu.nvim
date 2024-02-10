import requests
import iterm2
import glob
import os
import argparse
import cv2
from PIL import Image
from io import BytesIO
from datetime import datetime


API_FOR_WAIFUS = "https://api.waifu.pics/"

# Create an ArgumentParser object
parser = argparse.ArgumentParser(description="A tool to set your iterm2 background to a new waifu each day")

# Define command-line arguments
parser.add_argument("-i",  "--img_dir", type=str, default=os.path.expanduser("~/Desktop/waifus"), help="path to dir for saving images")
parser.add_argument("-z", "--cascade", type=str, default=os.path.expanduser("~/.local/share/nvim/lazy/waifu.nvim/lbp_anime_face_detect.xml"), help="path to cascade classifier sheet for face detection")
parser.add_argument("-t", "--type", type=str, choices=["sfw", "nsfw"], help="Type of waifu (safe for work or not)", default="sfw")
parser.add_argument("-c", "--category", type=str, choices=["waifu", "neko", "shinobu","megumin","bully","cuddle","cry","hug","awoo",
                                                          "kiss","lick","pat","smug","bonk","yeet","blush","smile","wave","highfive",
                                                          "handhold","nom","bite","glomp","slap","kill","kick","happy","wink","poke",
                                                          "dance","cringe"], 
                    default="waifu",
                    help="category of waifu")
parser.add_argument("-v","--verbose", type=int, default=0, help="print additional information")
parser.add_argument("-b","--blending", type=float, default=0.15, help="image blend (transparency) 0-1")
parser.add_argument("-m","--image_mode", type=str, default="fill", choices=["fill","fit","stretch","tile"], help="image fill mode")
parser.add_argument("-r","--crop", type=int, default=0, choices=[0,1,2], help="try to crop image to fit terminal \n 0 - no crop \n 1 - crop to aspect ratio (set with -h and -w) \n 2 - crop to faces")
parser.add_argument("-y","--height", type=int, default=10, help="aspect ratio height for crop")
parser.add_argument("-x","--width", type=int, default=16, help="aspect ratio width for crop")
parser.add_argument("-g","--generate", type=int, default=0, help="generate a new image for the day")

# Parse the command-line arguments
args = parser.parse_args()

PATH_TO_WAIFU_DIR = args.img_dir 


def get_image_mode(mode):
    img_mode = iterm2.BackgroundImageMode(2)
    if mode=="stretch": img_mode = iterm2.BackgroundImageMode(0)
    elif mode=="fit": img_mode = iterm2.BackgroundImageMode(3)
    elif mode=="tile": img_mode = iterm2.BackgroundImageMode(1)
    return img_mode.toJSON()

def print_v(string):
    if args.verbose:
        print(string)

def crop_aspect_ratio(img, width, height):
    target_height = int(img.width * (height / width))
    # Calculate the cropping box (left, upper, right, lower)
    crop_box = (
        0,
        0,
        img.width,
        target_height
    )

    # Crop the image
    img = img.crop(crop_box)
    print_v(f"Cropped to {args.width}:{args.height}")
    return img

def crop_face(file_path):
    img = cv2.imread(file_path)
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_gray = cv2.equalizeHist(img_gray) 
    face_cascade = cv2.CascadeClassifier(args.cascade)
    faces = face_cascade.detectMultiScale(img_gray)

    face_bounds = 500

    for x, y, w, h in faces:
        print_v("Faces found")
        x = max(0,x-face_bounds)
        y = max(0,y-face_bounds)
        height, width, _ = img.shape
        w = min(w+face_bounds,width)
        h = min(h+face_bounds,height)
        cropped_image = img[y:y+h, x:x+w]

        # Save the cropped image
        cv2.imwrite(file_path, cropped_image)
        return

    print_v("No faces detected.")
    return img


def crop_save_img(img_content, save_path):
    img = Image.open(BytesIO(img_content))

    if args.crop == 1:
        img = crop_aspect_ratio(img, args.width, args.height)

    img.save(save_path)

    if args.crop == 2:
        crop_face(save_path)



def get_waifu(date) -> str:
    waifu_type = 'sfw'
    category = 'waifu'
    url = f'{API_FOR_WAIFUS}{waifu_type}/{category}'

    response = requests.get(url)

    save_path = "error"

    if response.status_code == 200:
        img_url = response.json()["url"]
        print_v(f"successfully got image url: {img_url}")
        filetype = img_url.rsplit('.',1)[-1]

        save_path = f'{PATH_TO_WAIFU_DIR}/{date}.{filetype}'

        img_res = requests.get(img_url)
        if img_res.status_code == 200:
            print_v(f'successfully got image: {img_res}')
            crop_save_img(img_res.content, save_path)
            print_v(f'successfully saved image: {save_path}')

    return save_path

def get_waifu_path(formatted_date) -> str: 
    daily_waifu = glob.glob(f"{PATH_TO_WAIFU_DIR}/{formatted_date}.*")
    
    if not daily_waifu or args.generate != 0:
        daily_waifu = [get_waifu(formatted_date)]
        
    return daily_waifu[0]

def clean_waifu_folder(today_path):
    files = glob.glob(os.path.join(PATH_TO_WAIFU_DIR,"*"))

    print_v("cleaning old images")
    for file in files:
        if file != today_path:
            try:
                os.remove(file)
                print_v(f"Deleted: {file}")
            except OSError as e:
                print_v(f"Error deleting {file}: {e}")

async def main(connection):
    # Get waifu for the day
    formatted_date = formatted_date = datetime.now().strftime("%Y-%m-%d")
    img_path = get_waifu_path(formatted_date)

    if img_path != "error":
        # set as background if new image
        app = await iterm2.async_get_app(connection)
        session=app.current_terminal_window.current_tab.current_session
        profile=await session.async_get_profile()
        print_v(f"profile: {profile}")

        await profile.async_set_background_image_location("") # force update
        await profile.async_set_background_image_location(img_path)
        await profile.async_set_blend(args.blending)
        await profile.async_set_background_image_mode(get_image_mode(args.image_mode))

        # clean up waifu folder if successful
        clean_waifu_folder(img_path)
    
iterm2.run_until_complete(main)
