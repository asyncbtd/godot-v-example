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
import math

@[godot.extends('Area2D')]
pub struct Player {}

pub fn player_enter() {
	mut self := Player{}
	self.ready()
}

pub fn player_frame(delta f64) {
	mut self := Player{}
	self.process(delta)
}

pub fn player_signal(name string) bool {
	mut self := Player{}
	if name == 'start' {
		self.start()
		return true
	}
	if name == 'on_body_entered' {
		self.on_body_entered()
		return true
	}
	if name == '_ready' {
		self.ready()
		return true
	}
	if name == '_process' {
		self.process(godot.delta_of(godot.owner()))
		return true
	}
	return false
}

pub fn (mut self Player) ready() {
	width, height := godot.viewport_size(godot.owner())
	godot.live().screen_w = width
	godot.live().screen_h = height
	godot.hide_node(godot.owner())
}

pub fn (mut self Player) start() {
	marker := godot.node_at(godot.owner(), '../StartPosition')
	mut x := f32(240)
	mut y := f32(450)
	if marker != unsafe { nil } {
		x, y = godot.position_of(marker)
	}
	godot.move_to(godot.owner(), x, y)
	godot.set_rotation(godot.owner(), 0)
	godot.show_node(godot.owner())
	godot.set_disabled(godot.node_at(godot.owner(), 'CollisionShape2D'), false)
}

pub fn (mut self Player) on_body_entered() {
	godot.hide_node(godot.owner())
	godot.call_method(godot.parent_of(godot.owner()), 'game_over')
	godot.set_deferred_flag(godot.node_at(godot.owner(), 'CollisionShape2D'), 'disabled', true)
}

pub fn (mut self Player) process(delta f64) {
	mut x := f32(0)
	mut y := f32(0)
	if godot.action_down('move_right') {
		x += 1
	}
	if godot.action_down('move_left') {
		x -= 1
	}
	if godot.action_down('move_down') {
		y += 1
	}
	if godot.action_down('move_up') {
		y -= 1
	}
	sprite := godot.node_at(godot.owner(), 'AnimatedSprite2D')
	length := f32(math.sqrt(f64(x * x + y * y)))
	if length > 0 {
		x = x / length * 400
		y = y / length * 400
		godot.play_anim(sprite, '')
	} else {
		godot.stop_anim(sprite)
	}
	px, py := godot.position_of(godot.owner())
	godot.move_to(godot.owner(), clamp_f(px + x * f32(delta), 0, godot.live().screen_w), clamp_f(py + y * f32(delta),
		0, godot.live().screen_h))
	if x != 0 {
		godot.set_text_prop(sprite, 'animation', 'right')
		godot.set_flag_prop(sprite, 'flip_h', x < 0)
	} else if y != 0 {
		godot.set_text_prop(sprite, 'animation', 'up')
		if y > 0 {
			godot.set_rotation(godot.owner(), math.pi)
		} else {
			godot.set_rotation(godot.owner(), 0)
		}
	}
}

fn clamp_f(value f32, lo f32, hi f32) f32 {
	if value < lo {
		return lo
	}
	if value > hi {
		return hi
	}
	return value
}
