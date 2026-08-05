import sys
import subprocess

platform = ""

def build() -> None:
    match sys.platform.lower():
        case "linux":   platform = "linux"
        case "darwin":  platform = "macos"
        case "win32":   platform = "windows"
        case _:         print("Error: Unknown platform!")

    if platform != "":
        print(f"Flags: platform={platform}, bits=64")
        subprocess.run(["scons", f"platform={platform}", "bits=64"], shell=True)

if __name__ == "__main__":
    print("Nice try!...")