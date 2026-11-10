// Copyright 2026 Frigate Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module script

import asyncbtd.godot
import script.node
import script.scene

fn init() {
	godot.register_player(node.player_enter, node.player_frame, node.player_signal)
	godot.register_main(scene.main_enter, scene.main_signal)
	godot.register_mob(node.mob_enter)
}
