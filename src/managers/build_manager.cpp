#include "build_manager.hpp"


void BuildManager::_bind_methods(void) 
{
    godot::ClassDB::bind_method(godot::D_METHOD("get_build_container"), &BuildManager::get_dictionary);
    godot::ClassDB::bind_method(godot::D_METHOD("set_build_container", "buildings"), &BuildManager::set_dictionary);
    godot::ClassDB::add_property(
        "BuildManager", 
        godot::PropertyInfo(
            godot::Variant::ARRAY, 
            "Buildings"
        ),
        "set_build_container", 
        "get_build_container"
    );
}

bool BuildManager::add_building(Building* building)
{
    bool flag = true;

    if (!building)
    {
        flag = false;
    }

    if (flag)
    {
        container.append(building);
        this->add_child(building);
    }
    
    return flag;
}

bool BuildManager::remove_building(Building* building)
{
    bool flag = true;
    if (!building)
    {
        flag = false;
    }

    if (flag && container.has(building))
    {
        this->remove_child(building);
        container.erase(building);
    }

    return flag;
}