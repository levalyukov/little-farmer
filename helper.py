
#* Небольшой вспомагательный python-скрипт
#* ---------------------------------------
#* build     - Компилирует C++ все модули
#* format    - Форматирует .gd и C++ файлы
#* clear     - Очищает временные Godot

from helper.build   import build
from helper.format  import format
from helper.clear   import clear

def help() -> None:
    print("---- Project Helper ----")
    print("\t1. build\t - Compiling all .cpp modules")
    print("\t2. format\t - Formatting GDscript and C++ files")
    print("\t3. clear\t - Clering trash")
    print("\t0. (e)xit\t - Exit")

def main() -> None:
    while 1:
        help()
        command = input("Select the command: ")
        print() # Разделитель
        match command:
            case "build"  | "1":    build()
            case "format" | "2":    format()
            case "clear"  | "3":    clear()
            case "exit"   | "0" | "e":   break
            case _: print("Error: Unknown command")

if __name__ == "__main__":
    main()
