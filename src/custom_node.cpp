#include "custom_node.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void CustomNode::_bind_methods() {
}

CustomNode::CustomNode() {
	// Initialize any variables here.
	time_passed = 0.0F;
}

CustomNode::~CustomNode() {
	// Add your cleanup here.
}

void CustomNode::_process(double delta) {
	time_passed += delta;

	Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));

	set_position(new_position);
}