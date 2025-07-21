use godot::prelude::*;
use godot::classes::Control;
use godot::classes::IControl;

#[derive(GodotClass)]
#[class(base=Control)]
struct LevelEditor {
    camera_rect: Rect2,
    last_place: Vector2,
    drag_start_cursor_position: Vector2,
    drag_start_camera_position: Vector2,
    selected_object: u32,
    block_input: bool,
    swipe: bool,

    level_path: VariantArray,
    current_level: u32,
    // level: Gd<level_data>,
    // stored_level: level_data,
    object_map: VariantArray,

    base: Base<Control>
}

#[godot_api]
impl IControl for LevelEditor {
    fn init(base: Base<Control>) -> Self {

        Self {
            camera_rect: Rect2 { position: Vector2 { x: 0.0, y: 0.0 }, size:  Vector2 { x: 0.0, y: 0.0 }},
            last_place: Vector2 { x: 0.0, y: 0.0 },
            drag_start_cursor_position: Vector2 { x: 0.0, y: 0.0 },
            drag_start_camera_position: Vector2 { x: 0.0, y: 0.0 },
            selected_object: 1,
            block_input: false,
            swipe: false,

            level_path: array![],
            current_level: 0,
            // level: level_data,
            // stored_level: level_data,
            object_map: array![],

            base,
        }
    }

    fn ready(&mut self) {


    }

    fn process(&mut self, delta: f64) {

    }
}
