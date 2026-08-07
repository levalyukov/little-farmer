
#* Небольшой вспомагательный python-скрипт
#* ---------------------------------------
#* build     - Компилирует все модули C++
#* format    - Форматирует .gd и C++ файлы
#* linter    - Проверяет синтаксические ошибки
#* clear     - Очищает временные Godot

from helper.build   import build
from helper.format  import format
from helper.linter  import linter
from helper.clear   import clear

def help() -> None:
    print("---- Project Helper ----")
    print("\t1. build\t - Compiling all .cpp modules")
    print("\t2. format\t - Formatting GDscript and C++ files")
    print("\t3. linter\t - Liting GDscript and C++ files")
    print("\t4. clear\t - Clering trash")
    print("\t0. (e)xit\t - Exit")

def main() -> None:
    while 1:
        help()
        command = input("Select the command: ")
        print() # Разделитель
        match command:
            case "1" | "build" : build()
            case "2" | "format": format()
            case "3" | "linter": linter()
            case "4" | "clear" : clear()
            case "0" | "exit" | "e": break
            case _: print("Error: Unknown command")

if __name__ == "__main__":
    main()
