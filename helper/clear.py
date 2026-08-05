from helper import *

IMPORT = "./.import"
EXTENSIONS = [".cfg", ".tscn-", ".tmp", ".save", ".dmp", ".ctex", ".import", ".oggvorbisstr", "uid", ".cache"]
PROTECTED = [
    "global_script_class_cache.cfg", 
    "project_metadata.cfg", 
    "script_editor_cache.cfg", 
    "editor_layout.cfg"
]

def clear() -> None:
    if os.path.exists(IMPORT):
        shutil.rmtree(IMPORT)
        print(f"Removed: {IMPORT}")

    for root, dirs, files in os.walk("."):
        for file in files:
            if file in PROTECTED:
                print(f"Protected file, not removed: {file}")
                continue

            if any(file.endswith(ext) for ext in EXTENSIONS):
                file_path = os.path.join(root, file)
                os.remove(file_path)
                print(f"Removed: {file_path}")

if __name__ == "__main__":
    print("Nice try!...")