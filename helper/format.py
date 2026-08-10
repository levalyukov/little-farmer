from helper import *

SCRIPTS = "assets/scripts/"

def format() -> None:
    gdscripts_files = []
    for (dirpath, dirnames, filenames) in os.walk(SCRIPTS):
        for filename in filenames:
            gdscripts_files.append(os.path.join(dirpath, filename))

    if len(gdscripts_files) > 0:
        for gd in gdscripts_files:
            subprocess.call(["gdformat", gd], shell=True)

if __name__ == "__main__":
    print("Nice try!...")