#!/usr/bin/env python
import os
import sys

FILES = "src/"
OUTPUT = "modules/"

env = SConscript("godot-cpp/SConstruct")
env.Append(CPPPATH=[FILES], CCFLAGS=[])

if env["platform"] == "windows":
    env.Append(
        CCFLAGS=[
            "/std:c++17", "/permissive-", "/external:I", "godot-cpp/include", 
            "/external:I", "godot-cpp/gen/include", "/external:W0", "/external:templates-"
        ]
    )

elif env["platform"] in ["linux", "macos"]:
    env.Append(
        CCFLAGS=[
            "-std=c++17", "-Wall", "-Wextra", "-Werror", "-Wpedantic",
            "-Wshadow", "-Wconversion", "-Wsign-conversion", "-Wold-style-cast", 
            "-Wunused", "-Wcast-align", "-Wformat=2", "-Wlogical-op", "-Wmissing-declarations",
            "-Woverloaded-virtual", "-Wctor-dtor-privacy", "-Wnon-virtual-dtor", "-Wnull-dereference",
            "-Wdouble-promotion","-Wduplicated-branches","-Wduplicated-cond","-fstack-protector-strong",
            "-D_FORTIFY_SOURCE=3", "-isystem", "godot-cpp/include", "-isystem", "godot-cpp/gen/include"
        ]
    )

sources = []

for root, dirs, files in os.walk("src"):
    for file in files:
        if file.endswith(".cpp"):
            sources.append(os.path.join(root, file))

if env["platform"] == "macos":
    library = env.SharedLibrary(
        OUTPUT+"libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
    
elif env["platform"] == "ios":
    if env["ios_simulator"]:
        library = env.StaticLibrary(
            OUTPUT+"libgdexample.{}.{}.simulator.a".format(env["platform"], env["target"]),
            source=sources,
        )
    else:
        library = env.StaticLibrary(
            OUTPUT+"libgdexample.{}.{}.a".format(env["platform"], env["target"]),
            source=sources,
        )
else:
    library = env.SharedLibrary(
        OUTPUT+"libgdexample{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
