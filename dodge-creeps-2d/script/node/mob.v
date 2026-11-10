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

module node

import asyncbtd.godot
import rand

@[godot.extends('RigidBody2D')]
pub struct Mob {}

pub fn mob_enter() {
	mut self := Mob{}
	self.ready()
}

pub fn (mut self Mob) ready() {
	names := ['fly', 'swim', 'walk']
	sprite := godot.node_at(godot.owner(), 'AnimatedSprite2D')
	godot.set_text_prop(sprite, 'animation', names[rand.intn(names.len) or { 0 }])
	godot.play_anim(sprite, '')
}
