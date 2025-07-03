import os
import shutil

import_dir = "./.import"
extensions = [".cfg", ".tscn-", ".tmp", ".save", ".dmp", ".ctex", ".import", ".oggvorbisstr"]
protected_files = [
    "global_script_class_cache.cfg", 
    "project_metadata.cfg", 
    "script_editor_cache.cfg", 
    "editor_layout.cfg"
    ]

if os.path.exists(import_dir):
    shutil.rmtree(import_dir)
    print(f"Removed: {import_dir}")

for root, dirs, files in os.walk("."):
    for file in files:
        if file in protected_files:
            print(f"Protected file, not removed: {file}")
            continue

        if any(file.endswith(ext) for ext in extensions):
            file_path = os.path.join(root, file)
            os.remove(file_path)
            print(f"Removed: {file_path}")