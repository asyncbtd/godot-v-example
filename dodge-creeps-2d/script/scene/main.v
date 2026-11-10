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

module scene

import asyncbtd.godot
import math
import rand

@[godot.extends('Node')]
pub struct Main {}

pub fn main_enter() {
	mut self := Main{}
	self.ready()
}

pub fn main_signal(name string) bool {
	mut self := Main{}
	if name == 'new_game' {
		self.new_game()
		return true
	}
	if name == 'game_over' {
		self.game_over()
		return true
	}
	if name == '_ready' {
		self.ready()
		return true
	}
	if name == 'on_mob_timer_timeout' {
		self.on_mob_timer_timeout()
		return true
	}
	if name == 'on_score_timer_timeout' {
		self.on_score_timer_timeout()
		return true
	}
	if name == 'on_start_timer_timeout' {
		self.on_start_timer_timeout()
		return true
	}
	if name == 'on_message_timer_timeout' {
		self.on_message_timer_timeout()
		return true
	}
	return false
}

pub fn (mut self Main) ready() {
	root := godot.owner()
	godot.connect(godot.node_at(root, 'HUD/StartButton'), 'pressed', root, 'new_game')
	godot.connect(godot.node_at(root, 'HUD/MessageTimer'), 'timeout', root, 'on_message_timer_timeout')
	self.update_score(0)
	godot.live().mob_scene = godot.load_resource('res://node/mob.tscn')
	if godot.live().mob_scene == unsafe { nil } {
		godot.report('mob scene failed to load')
	}
	if godot.feature('headless') {
		self.new_game()
	}
}

pub fn (mut self Main) game_over() {
	godot.timer_stop(godot.node_at(godot.owner(), 'ScoreTimer'))
	godot.timer_stop(godot.node_at(godot.owner(), 'MobTimer'))
	self.show_game_over()
	godot.audio_stop(godot.node_at(godot.owner(), 'Music'))
	godot.audio_play(godot.node_at(godot.owner(), 'DeathSound'))
}

pub fn (mut self Main) new_game() {
	godot.call_group(godot.owner(), 'mobs', 'queue_free')
	godot.live().score = 0
	godot.live().phase = 0
	godot.call_method(godot.node_at(godot.owner(), 'Player'), 'start')
	godot.timer_start(godot.node_at(godot.owner(), 'StartTimer'))
	self.update_score(0)
	self.show_message('Get Ready')
	godot.hide_node(godot.node_at(godot.owner(), 'HUD/StartButton'))
	godot.audio_play(godot.node_at(godot.owner(), 'Music'))
}

pub fn (mut self Main) on_mob_timer_timeout() {
	self.spawn_mob()
}

pub fn (mut self Main) on_score_timer_timeout() {
	godot.live().score++
	self.update_score(godot.live().score)
}

pub fn (mut self Main) on_start_timer_timeout() {
	godot.timer_start(godot.node_at(godot.owner(), 'MobTimer'))
	godot.timer_start(godot.node_at(godot.owner(), 'ScoreTimer'))
}

pub fn (mut self Main) on_message_timer_timeout() {
	if godot.live().phase == 1 {
		self.show_message('Dodge the\nCreeps')
		godot.live().phase = 2
		return
	}
	if godot.live().phase == 2 {
		godot.show_node(godot.node_at(godot.owner(), 'HUD/StartButton'))
		godot.live().phase = 0
		return
	}
	godot.hide_node(godot.node_at(godot.owner(), 'HUD/MessageLabel'))
}

fn (mut self Main) show_message(text string) {
	message := godot.node_at(godot.owner(), 'HUD/MessageLabel')
	godot.set_text_prop(message, 'text', text)
	godot.show_node(message)
	godot.timer_start(godot.node_at(godot.owner(), 'HUD/MessageTimer'))
}

fn (mut self Main) show_game_over() {
	godot.live().phase = 1
	self.show_message('Game Over')
}

fn (mut self Main) update_score(score int) {
	godot.set_text_prop(godot.node_at(godot.owner(), 'HUD/ScoreLabel'), 'text', '${score}')
}

fn (mut self Main) spawn_mob() {
	mob := godot.instance_scene(godot.live().mob_scene)
	follow := godot.node_at(godot.owner(), 'MobPath/MobSpawnLocation')
	nothing := unsafe { nil }
	if mob == nothing || follow == nothing {
		godot.report('mob instantiate failed')
		return
	}
	ratio := rand.f32()
	godot.set_progress_ratio(follow, f64(ratio))
	x, y := godot.position_of(follow)
	base := godot.rotation_of(follow)
	quarter := math.pi / 2
	mut direction := base + quarter
	spread := f64(rand.f32()) * quarter - math.pi / 4
	direction += spread
	godot.move_to(mob, x, y)
	godot.set_rotation(mob, direction)
	speed := f32(150) + rand.f32() * f32(100)
	vx := speed * f32(math.cos(direction))
	vy := speed * f32(math.sin(direction))
	godot.push_velocity(mob, vx, vy)
	godot.add_child(godot.owner(), mob)
}
