#pragma once
#ifndef FARMING_MANAGER_HPP

#include <godot_cpp/classes/node.hpp>

class FarmingManager : public godot::Node
{
    GDCLASS(FarmingManager, godot::Node)

  	public:
    	FarmingManager(void);
    	~FarmingManager();

	private:
		godot::Dictionary container;

	protected:
		static void _bind_methods(void);
};

#endif // FARMING_MANAGER_HPP