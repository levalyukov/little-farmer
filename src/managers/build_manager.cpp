#include "build_manager.hpp"

void BuildManager::_bind_methods(void) 
{
    BIND_ENUM_CONSTANT(NOTHING);
    BIND_ENUM_CONSTANT(DESTROY);
    BIND_ENUM_CONSTANT(WATERING);
    BIND_ENUM_CONSTANT(FARMING);
    BIND_ENUM_CONSTANT(HARVESTING);
    BIND_ENUM_CONSTANT(BUILD);

    godot::ClassDB::bind_method(godot::D_METHOD("get_build_container"), &BuildManager::get_dictionary);
    godot::ClassDB::bind_method(godot::D_METHOD("set_build_container", "Buildings"), &BuildManager::set_dictionary);
    godot::ClassDB::add_property(
        "BuildManager", 
        godot::PropertyInfo(
            godot::Variant::ARRAY, 
            "buildings"
        ),
        "set_build_container", 
        "get_build_container"
    );
}

BuildManager::BuildManager(void)
{
    init_nodes();
}

BuildManager::~BuildManager()
{
    deinit_nodes();
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

void BuildManager::init_nodes(void)
{}

void BuildManager::deinit_nodes(void)
{}