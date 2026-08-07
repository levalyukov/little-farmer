#pragma once
#ifndef BUILD_MANAGER_HPP

#include <stdbool.h>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include "../nodes/building.hpp"

class BuildManager : public godot::Node
{
    GDCLASS(BuildManager, Node)

  	public:
		bool add_building(Building* building);
		bool remove_building(Building* building);

		inline unsigned int get_max_distance(void) const
		{
			return MAX_DISTANCE;
		};

	private:
		godot::Array container;
		const unsigned int MAX_DISTANCE = 250;

	protected:
		static void _bind_methods(void);

		inline godot::Array get_dictionary(void) const 
		{
			return container;
		};

		inline void set_dictionary(godot::Array content) 
		{
			container = content;
		};
};

#endif // BUILD_MANAGER_HPP