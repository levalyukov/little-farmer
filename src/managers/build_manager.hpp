#pragma once
#ifndef BUILD_MANAGER_MODULE_HPP

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include "../nodes/building.hpp"

class BuildManager : public godot::Node
{
    GDCLASS(BuildManager, Node)

  	public:
    	BuildManager(void);
    	~BuildManager();

		bool add_build(void);
		godot::Building* get_build(unsigned int index) const;
		bool remove_build(void);

		inline unsigned int get_max_distance(void) const
		{
			return MAX_DISTANCE;
		};

	private:
		godot::Dictionary container;
		const unsigned int MAX_DISTANCE = 250U;

	protected:
		static void _bind_methods(void);

		inline godot::Dictionary get_dictionary(void) const 
		{
			return container;
		};

		inline void set_dictionary(godot::Dictionary content) 
		{
			container = content;
		};
};

#endif //! BUILD_MANAGER_MODULE_HPP