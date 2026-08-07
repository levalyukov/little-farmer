from helper import *

platform = ""

def build() -> None:
    match sys.platform.lower():
        case "linux":   platform = "linux"
        case "darwin":  platform = "macos"
        case "win32":   platform = "windows"
        case _:         print("Error: Unknown platform!")

    if platform != "":
        print(f"Flags: platform={platform}")
        subprocess.run(["scons", f"platform={platform}"], shell=True)

if __name__ == "__main__":
    print("Nice try!...")