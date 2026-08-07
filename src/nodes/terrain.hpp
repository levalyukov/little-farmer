#pragma once
#ifndef TERRAIN_INTERFACE_HPP

#include <godot_cpp/classes/node2D.hpp>

class Terrain : public godot::Node2D
{
    public:
        virtual ~Terrain();
};

#endif // TERRAIN_INTERFACE_HPP