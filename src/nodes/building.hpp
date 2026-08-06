#pragma once
#ifndef BUILDING_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/sprite2d.hpp>

namespace godot
{

class Building : public Node2D
{
    GDCLASS(Building, Node2D)

  	public:
    	Building(void);
    	~Building();

	protected:
		static void _bind_methods(void);
};

}

#endif //! BUILDING_HPP