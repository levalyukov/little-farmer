#pragma once

#include <godot_cpp/classes/node.hpp>

class FarmingManager : public godot::Node
{
    GDCLASS(FarmingManager, Node)

  	public:
    	FarmingManager(void);
    	~FarmingManager();

	protected:
		static void _bind_methods();
};