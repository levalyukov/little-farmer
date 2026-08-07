#pragma once

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/variant/dictionary.hpp>

class Plant : public godot::Node2D
{
    public:
        virtual godot::Dictionary& get_plant_data(void);
};