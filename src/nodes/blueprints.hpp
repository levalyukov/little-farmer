#pragma once
#ifndef BLUEPRINTS_HPP

#include <stdint.h>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/classes/texture2d.hpp>

#include "building.hpp"
#include "terrain.hpp"

class Blueprints
{
    public:
        typedef struct
        {
            godot::String title;
            godot::String description;
            godot::Ref<godot::Texture2D> icon;
            Building* node;
            Terrain* terrain;
        } Blueprint;

    private:
        
};

#endif // BLUEPRINTS_HPP