pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--wander kid
--by ivan almanza

--game state

debug = false
transition_radius = 1
transition_time = 25 --half a second
tran_dt = 0
transitioning = false
level = 0
offset_ss=0 --screen shake offset
shake = false
ss_time = 0
next_scene = "game"
transition_color = 6
tran_flash = 0

--debug variables

function _init()
 palette_setup()
 init_menu()
 _update = update_menu
 _draw = draw_menu

 --temporal (just for quick testing)
 --init_game()
 --_update = update_game
 --_draw = draw_game

 --_update = update_game_over
 --_draw = draw_game_over

 --_update = update_victory_screen
 --_draw = draw_victory_screen
end

function palette_setup()
 poke(0x5f2e,1) --prevent from resetting the colors
 --palette setup thanks to palette maker tool
 ------0, 1,2,3,4,5,6,7,8, 9, 10, 11, 12, 13, 14, 15
 _pal={12,0,1,3,4,6,7,8,9,128,131,132,133,139,140,143}
 --for i,c in pairs(_pal) do
 	--pal(i-1,c,1)
 --end
 for i = 0, 15 do
  poke(0x5f10+i,_pal[i+1])
 end
 palt(0, true) -- blue color as transparency is true
 palt(1, false) -- black color as transparency is false
end

function init_menu()
 title = {}
 title.x = -14
 title.y = -16
 title.min_y = title.y - 3
 title.max_y = title.y + 3
 title.timer = 0
 oval_floor = {}
 oval_floor.x = 15
 oval_floor.y = 77
 oval_floor.w = 96
 oval_floor.h = 20
 oval_floor.size = 0
 oval_floor.max_x = oval_floor.x
 oval_floor.min_x = oval_floor.x - oval_floor.size
 oval_floor.max_w = oval_floor.w + oval_floor.size
 oval_floor.min_w = oval_floor.w
 oval_floor.timer = 0
 fire = {}
 fire.x = 47
 fire.y = oval_floor.y - 4
 fire.sprite = 162
 fire.anim = {160,162,164,166}
 fire.base_spr = 168
 fire.base_x = fire.x - 8
 fire.base_y = fire.y + 6
 fire.anim_i = 1
 fire.anim_time = 0
 fire.anim_speed = 0.09
 kid = {}
 kid.x = fire.x + 18
 kid.y = fire.y + 2
 kid.sprite = 170
 kid.anim = {170,172}
 kid.anim_i = 1
 kid.anim_time = 0
 kid.anim_speed = 1
 init_smoke_particles()
 music(1)
end

function update_menu()
 if btnp(5) then
  music(-1, 300)
  sfx(0)
  next_scene = "game"
  transition_radius = 0
  tran_dt = 0
  transition_color = 6
  transitioning = true
  level = 0
  _update = update_transition_out
  _draw = draw_transition_out
 end
 menu_animation()
end

function draw_menu()
 cls(1)
 --scenery
 ovalfill(oval_floor.x,oval_floor.y,oval_floor.x+oval_floor.w,
 oval_floor.y+oval_floor.h,9)
 draw_smoke_particles()
 spr(fire.sprite,fire.x,fire.y,2,2)
 spr(fire.base_spr,fire.base_x,fire.base_y,2,2)
 spr(fire.base_spr,fire.base_x+16,fire.base_y,2,2,true)
 spr(kid.sprite,kid.x,kid.y,2,2)
 --credits
 rectfill(0,120,128,128,10)
 credits = "by @iv4n_algo"
 print(credits,hcenter(credits),121,1)
 --play text
 play_text = "PRESS ❎ TO PLAY "
 print(play_text, hcenter(play_text), 108, 6)
 --[[
 title = "wander kid v0.1"
 print(title, hcenter(title), 50, 6)
 ]]--
 --title
 map(0,16,title.x,title.y,16,16)
 --draw_screen_guides()
end

function menu_animation()
 --fire animation
 if time() - fire.anim_time > fire.anim_speed then
  fire.anim_i = anim_loop(fire.anim,fire,fire.anim_i)
 end
 --kid animation
 if time() - kid.anim_time > kid.anim_speed then
  kid.anim_i = anim_loop(kid.anim,kid,kid.anim_i)
 end
 --floor animation
 oval_floor.timer = 1 - abs(time()/2 % 2 - 1)
 oval_floor.size = lerp(3,0,oval_floor.timer)
 oval_floor.x = oval_floor.min_x - oval_floor.size
 oval_floor.w = oval_floor.min_w + oval_floor.size
 --title animation
 title.timer = mid(1.5-abs(time()/2%4-1.5),0,1)
 title.y = lerp(title.max_y,title.min_y,title.timer)
 --particles
 update_smoke_particles()
end

function init_game()
 --table that contains objects that need to be sorted
 game_objects = {}
 init_level_settings()
 init_player()
 init_bounds()
 init_bushes()
 init_traps()
 init_ui()
 init_bullets()
 init_squirrels()
 init_particles_system()
 tran_dt = 0
 transitioning = true
 game_can_start = false
 music(0,0,3)
end

function update_game()
 if game_can_start then
  update_bushes()
  update_traps()
  update_bullets()
  update_squirrels()
 end
 update_player()
 update_particles()

 if transitioning and level_completed == false then
  update_transition_in()
 elseif transitioning and level_completed then
  update_transition_out()
 end
 level_controller()
 --screen shake
 offset_ss=0.01
 if shake then
  ss_time+=1
  if ss_time > 15 then
   shake = false
   ss_time = 0
   camera(0,0)
  end
 end

 update_ui()
end

function draw_game()
 cls(4)
 if shake then
  screen_shake()
 end

 draw_floor()
 draw_shadows()
 sort(game_objects,y_comparison)
 --draw_player()
 draw_particles()
 draw_game_objects()
 draw_bounds()
 draw_bullets()
 draw_ui()
 --transitions
 if transitioning and level_completed == false then
  draw_transition_in()
 elseif transitioning and level_completed then
  draw_transition_out()
 end
end

function init_level_settings()
 level+=1
 level_completed = false
 can_escape = false
 if level == 1 then
  berries_to_collect = 2
  sqrls_to_collect = 0
  traps_in_level = 0
  b_spawn_rate = 20
 elseif level == 2 then
  berries_to_collect = 1
  sqrls_to_collect = 3
  traps_in_level = 1
  b_spawn_rate = 30
 elseif level == 3 then
  berries_to_collect = 3
  sqrls_to_collect = 2
  traps_in_level = 3
  b_spawn_rate = 30
 elseif level == 4 then
  berries_to_collect = 4
  sqrls_to_collect = 4
  traps_in_level = 4
  b_spawn_rate = 25
 elseif level == 5 then
  berries_to_collect = 0
  sqrls_to_collect = 9
  traps_in_level = 10
  b_spawn_rate = 30
 elseif level == 6 then
  berries_to_collect = 7
  sqrls_to_collect = 3
  traps_in_level = 6
  b_spawn_rate = 25
 elseif level == 7 then
  berries_to_collect = 5
  sqrls_to_collect = 8
  traps_in_level = 8
  b_spawn_rate = 30
 elseif level == 8 then
  berries_to_collect = 6
  sqrls_to_collect = 6
  traps_in_level = 7
  b_spawn_rate = 25
 elseif level == 9 then
  berries_to_collect = 8
  sqrls_to_collect = 7
  traps_in_level = 5
  b_spawn_rate = 30
 elseif level == 10 then
  berries_to_collect = 9
  sqrls_to_collect = 9
  traps_in_level = 4
  b_spawn_rate = 26
 end
end

function level_controller()
 if player.berries == berries_to_collect
 and player.sqrls == sqrls_to_collect  then
  if not can_escape then
   sfx(6)
  end
  can_escape = true
 end
end

function update_transition_out()
 transition_radius += 4
 tran_dt += 1

 if tran_dt >= transition_time
 and transitioning == true then
  transitioning = false
  --maybe change here to reuse transition with other "scenes"
  if next_scene == "game" then
   init_game()
   _update = update_game
   _draw = draw_game
  elseif next_scene == "game_over" then
   _update = update_game_over
   _draw = draw_game_over
  elseif next_scene == "menu" then
   init_menu()
   _update = update_menu
   _draw = draw_menu
  elseif next_scene == "victory" then
   _update = update_victory_screen
   _draw = draw_victory_screen
  end
 end
end

function draw_transition_out()
 circfill(63, 63, transition_radius, transition_color)
end

function update_transition_in()
 transition_radius -= 4
 tran_dt += 1
 if tran_dt >= transition_time
 and transitioning == true then
  transitioning = false
  game_can_start = true
 end
end

function draw_transition_in()
 circfill(63, 63, transition_radius, transition_color)
 if level <= 10 then
  tran_flash+=0.5
  day_txt = "day "..level
  outline_text(day_txt,hcenter(day_txt),
  62,1,6+tran_flash%2)
 end
end

function update_game_over()
 if btnp(4) then
  --go to title screen
  sfx(0)
  next_scene = "menu"
  transition_radius = 0
  tran_dt = 0
  transition_color = 6
  transitioning = true
  _update = update_transition_out
  _draw = draw_transition_out
 end
end

function draw_game_over()
 cls(1)
 --circfill(64, 70, 8, 2)
 hunted_txt = "you got hunted"
 outline_text(hunted_txt,hcenter(hunted_txt),40,6,1)
 return_txt = "🅾️:MENU "
 player.x = 57
 player.y = 60
 --draw_player()
 outline_sprite(player.sprite,6,player.x,player.y,2,2,
 false,false,true)
 outline_text(return_txt,hcenter(return_txt),90,6,1)
end

function update_victory_screen()
 if btnp(4) then
  --go to title screen
  sfx(0)
  next_scene = "menu"
  transition_radius = 0
  tran_dt = 0
  transition_color = 1
  transitioning = true
  _update = update_transition_out
  _draw = draw_transition_out
 end
 player.state = "front_idle"
 player_animation()
end

function draw_victory_screen()
 cls(8)
 victory01_txt = "congratulations,"
 victory02_txt = "you escaped from the woods"
 outline_text(victory01_txt,hcenter(victory01_txt),32,1,6)
 outline_text(victory02_txt,hcenter(victory02_txt),40,1,6)
 return_txt = "🅾️:MENU "
 player.x = 57
 player.y = 60
 draw_player()
 outline_text(return_txt,hcenter(return_txt),90,6,1)
end

-->8
--utilities
--function to center text
function hcenter(s)
  -- screen center minus the
  -- string length times the
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
--just for debug and positioning text purposes
function draw_screen_guides()
 --guides
 rect(0, 0, 127, 127, 7)
 line(63, 0, 63, 127, 7)
 line(31, 0, 31, 127, 7)
 line(95, 0, 95, 127, 7)
end

function y_comparison(a,b)
 if a.y == nil or a.h == nil then
  return false
 end
 return a.y + a.h >
 b.y + b.h
end

function sort(table, comparison)
 for i=1,#table do
  local j = i
  while j > 1
  and comparison(table[j-1],table[j]) do
   --swap
   table[j],table[j-1] =
   table[j-1],table[j]
   j-=1
  end
 end
end

function box_hit(x1,y1,w1,h1,x2,y2,w2,h2)
 local hit = false
 if x1 < x2 + w2 and x1 + w1 > x2 and
    y1 < y2 + h2 and y1 + h1 > y2 then
   hit = true
 end
 return hit
end

function circ_box_hit(b_x,b_y,b_w,b_h,c_x,c_y,c_r)
 local closest_x = mid(c_x, b_x, b_x+b_w)
 local closest_y = mid(c_y, b_y, b_y+b_h)

 local hit = false
 local _dx = closest_x-c_x
 local _dy = closest_y-c_y
 local squaredDist = _dx*_dx+_dy*_dy
 if squaredDist < c_r*c_r then
  --hit
  hit = true
 end
 return hit
end

function draw_game_objects()
 for game_object in all(game_objects) do
  game_object:draw()
 end
end

function anim_loop(anim,object,_i)
 if _i > #anim then
  _i = 1
 end
 object.sprite = anim[_i]
 object.anim_time = time()
 _i+=1
 return _i
end
--outline function by 24appnet
function outline_text(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end
--screen shake thanks to doc_robs
function screen_shake()
  local fade = 0.95
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=offset_ss
  offset_y*=offset_ss

  camera(offset_x,offset_y)
  offset_ss*=fade
  if offset_ss<0.05 then
    offset_ss=0
  end
end
--lerp function thanks to demo-man
function lerp(A, B, t)
   return A + (B-A)*t
end
--outline sprites thanks to liquidream
function outline_sprite(n,col_outline,x,y,w,h,flip_x,flip_y,_highlight)
 if _highlight then
  -- reset palette to black
  for c=1,15 do
    pal(c,col_outline)
  end
  -- draw outline
  for xx=-1,1 do
    for yy=-1,1 do
      spr(n,x+xx,y+yy,w,h,flip_x,flip_y)
    end
  end
  -- reset palette
  pal()
  palette_setup()
 end
 -- draw final sprite
 spr(n,x,y,w,h,flip_x,flip_y)
end

-->8
--gameplay
--player
function init_player()
 player = {}
 player.x = 55
 player.y = 80
 player.w = 12
 player.h = 16
 player.y_offset = 7
 player.x_offset = 3
 player.foot_x_offset = 5
 player.foot_y_offset = 13
 player.knife_x_offset = 10 --10 & -5
 player.knife_y_offset = 0
 player.col_w = player.w-player.x_offset
 player.col_h = player.h-player.y_offset
 player.foot_w = 5
 player.foot_h = 3
 player.knife_w = 10
 player.knife_h = 18
 player.sprite = 0
 player.flipped = false
 player.up = false
 player.running = false
 player.speed = 2
 player.state = "front_idle"
 player.anim_time = 0
 player.anim_i = 1
 player.idle_anim_speed = 0.1
 player.front_idle_anim = {0,2,4}
 player.back_idle_anim = {6,8,10}
 player.front_run_anim = {32,34,36,38}
 player.back_run_anim = {40,42,44,46}
 player.death_anim = {12,14}
 player.draw = draw_player
 player.searching = false
 player.berries = 0
 player.sqrls = 0
 player.can_move = true
 player.dead = false
 player.dead_by_trap = false
 player.death_timer = 0
 player.attacking = false
 player.attack_button_pressed = false
 player.walking_btns_pressed = false
 player.shadow = true
 player.shadow_x = player.x+2
 player.shadow_y = player.y+13
 player.shadow_w = 11
 player.shadow_h = 4
 add(game_objects, player)

 init_knife()
end

function update_player()
 if player.dead == false then
  player_interactions()
  if player.can_move then
   player_movement()
   update_knife()
  end
  player_state()
  player_animation()

  check_player_shooted()
 else
  player_death()
 end
end

function draw_player()
 spr(player.sprite,player.x,player.y,2,2,player.flipped)
 if debug == true then
  rect(player.x+player.x_offset,player.y+player.y_offset,
  player.x+player.w,player.y+player.h,7)
  rect(player.x+player.foot_x_offset,player.y+player.foot_y_offset,
  player.x+player.foot_w+player.foot_x_offset,
  player.y+player.foot_h+player.foot_y_offset,8)

  rect(player.x+player.knife_x_offset,
  player.y+player.knife_y_offset,
  player.x+player.knife_x_offset+player.knife_w,
  player.y+player.knife_y_offset+player.knife_h)
 end

 if player.dead == false then
  draw_knife()
 end
end

function player_movement()
 if btn(0) then
  player.x -= player.speed
  player.running = true
  player.up = false
  player.flipped = true
  knife.x_flipped = true
  knife.x_offset = -4
  knife.motion.flipped = true
  knife.motion.x_offset = -10
  player.knife_x_offset = -5
  if player.x <= 9 then
   player.x = 9
   player.running = false
  end
 elseif btn(1) then
  player.x += player.speed
  player.running = true
  player.up = false
  player.flipped = false
  knife.x_flipped = false
  knife.x_offset = 12
  knife.motion.flipped = false
  knife.motion.x_offset = 2
  player.knife_x_offset = 10
  if player.x >= 103 then
   player.x = 103
   player.running = false
  end
 elseif btn(2) then
  player.y -= player.speed
  player.running = true
  player.up = true
  if player.y <= -1 and can_escape == false then
   player.y = -1
   player.running = false
  elseif can_escape and player.y < -16 then
   level_completed = true
   if level == 10 then
    next_scene = "victory"
    transition_color = 8
   end
   if transitioning == false then
    sfx(8)
    music(-1, 300)
    player.can_move = false
    tran_dt = 0
    transitioning = true
   end
  end
 elseif btn(3) then
  player.y += player.speed
  player.running = true
  player.up = false
  if player.y >= 112 then
   player.y = 112
   player.running = false
  end
 else
  player.running = false
 end

 player.shadow_x = player.x+2
 player.shadow_y = player.y+13
 --foot sound
 --[[
 if btn(0) or btn(1) or btn(2) or btn(3) then
  if not player.walking_btns_pressed then
   player.walking_btns_pressed = true
   sfx(8,1)
  end
 else
  player.walking_btns_pressed = false
  sfx(-2,1)
 end
 ]]--
end

function player_state()
 if player.running == false then
  if player.up == true then
   player.state = "back_idle"
  else
   player.state = "front_idle"
  end
 else
  if player.up == true then
   player.state = "back_run"
  else
   player.state = "front_run"
  end
 end
end

function player_animation()
 if player.state == "front_idle" then
  if time() - player.anim_time >
  player.idle_anim_speed then
   player.anim_i = anim_loop(
   player.front_idle_anim,player,player.anim_i)
  end
 end
 if player.state == "back_idle" then
  if time() - player.anim_time >
  player.idle_anim_speed then
   player.anim_i = anim_loop(
   player.back_idle_anim,player,player.anim_i)
  end
 end
 if player.state == "front_run" then
  if time() - player.anim_time >
  player.idle_anim_speed then
   player.anim_i = anim_loop(
   player.front_run_anim,player,player.anim_i)
  end
 end
 if player.state == "back_run" then
  if time() - player.anim_time >
  player.idle_anim_speed then
   player.anim_i = anim_loop(
   player.back_run_anim,player,player.anim_i)
  end
 end
end

function player_interactions()
 --search in bushes
 if btn(5) then
  player.searching = true
 else
  player.searching = false
 end
 --attack squirrels
 if btn(4) then
  if not player.attack_button_pressed then
   player.attack_button_pressed = true
   player.attacking = true
   sfx(2)
  end
 else
  player.attack_button_pressed = false
 end
end

function check_player_shooted()
 for bullet in all(bullets) do
  if circ_box_hit(player.x+player.x_offset,
  player.y+player.y_offset,player.col_w,player.col_h,
  bullet.x+bullet.r,bullet.y+bullet.r,bullet.r) then
   music(-1, 300)
   bullet.debug_color = 8
   kid_death_ps(player.x+8,player.y+8,7)
   player.sprite = player.death_anim[1]
   player.dead = true
   shake = true
   bullet:hitted()
   sfx(7)
  else
   bullet.debug_color = 7
  end
 end
end

function player_death()
 player.death_timer+=1
 if player.death_timer == 20
 and player.dead_by_trap == false then
  player.sprite = player.death_anim[2]
 elseif player.death_timer > 30 then
  next_scene = "game_over"
  tran_dt = 0
  transition_color = 1--7
  transitioning = true
  _update = update_transition_out
  _draw = draw_transition_out
 end
end

--knife
function init_knife()
 knife = {}
 knife.x_offset = 12
 knife.y_offset = 5
 knife.x = player.x + knife.x_offset
 knife.y = player.y + knife.y_offset
 knife.sprite = 83 --83-84
 knife.x_flipped = false
 knife.y_flipped = false
 knife.anim_speed = 0.01
 knife.anim_time = 0
 knife.current_frame = 0

 knife.motion = {}
 knife.motion.x_offset = 2
 knife.motion.y_offset = -3
 knife.motion.x = knife.x + knife.motion.x_offset
 knife.motion.y = knife.y + knife.motion.y_offset
 knife.motion.spr = 104 --104-106
 knife.motion.flipped = false
 knife.motion.speed = 0.5
 knife.motion.anim_time = 0
end

function update_knife()
 knife.x = player.x + knife.x_offset
 knife.y = player.y + knife.y_offset
 knife.motion.x = knife.x + knife.motion.x_offset
 knife.motion.y = knife.y + knife.motion.y_offset
 knife_animation()
 knife_attack()
end

function draw_knife()
 spr(knife.sprite,knife.x,knife.y,1,1,
 knife.x_flipped,knife.y_flipped)
 if player.attacking then
  spr(knife.motion.spr,knife.motion.x,knife.motion.y,
  2,2,knife.motion.flipped)
 end
end

function knife_animation()
 if player.attacking then
  --attack animation
  if time() - knife.anim_time > knife.anim_speed then
   knife.current_frame += 1
   knife.anim_time = time()
   if knife.current_frame == 1 then
    knife.sprite = 83
    knife.y_flipped = false
    knife.y_offset = 5
    knife.motion.spr = 104
   elseif knife.current_frame == 2 then
    knife.sprite = 84
    knife.motion.spr = 106
   elseif knife.current_frame == 3 then
    knife.sprite = 83
    knife.y_flipped = true
    knife.y_offset += 7
   elseif knife.current_frame == 4 then
    knife.current_frame = 0
    player.attacking = false
    knife.y_offset = 5
   end
  end
 else
  --return to idle
  knife.sprite = 83
  knife.y_flipped = false
  knife.y_offset = 5
 end
end

function knife_attack()
 if player.attacking then
  for _squirrel in all(squirrels) do
   --evaluate if hited
   if box_hit(player.x+player.knife_x_offset,
   player.y+player.knife_y_offset,player.knife_w,player.knife_h,
   _squirrel.x,_squirrel.y,_squirrel.w,_squirrel.h)
   and _squirrel.hunted == false then
    sfx(3)
    shake = true
    sqrl_kill_ps(_squirrel.x+4,_squirrel.y+4,8)
    _squirrel.hunted = true
    _squirrel.shadow = false
    player.sqrls += 1
    sfx(4)
   end
  end
 end
end

-->8
--environment
function init_bounds()
 bounds = {}
 bounds.spr_corner = 128
 bounds.spr_btm_edge = 129
 bounds.spr_fill = {130,132}
 bounds.spr_edge = {131,133}
 --choose random floor
 floor = {0,16,32,48,64,80,96,112}
 floor_i = 1 + flr(rnd(8))
end
--all this just because you can't swap maps
--and i didn't wanted to waste sprite space:}
function draw_bounds()
 local j = 1
 for i = 0,14 do
  --left
  spr(bounds.spr_fill[j],0,8*i)
  spr(bounds.spr_edge[j],8,8*i)
  --right
  spr(bounds.spr_fill[j],120,8*i,1,1,true)
  spr(bounds.spr_edge[j],112,8*i,1,1,true)
  j+=1
  if j > 2 then
   j = 1
  end
 end
 --left
 spr(bounds.spr_corner,0,120)
 spr(bounds.spr_btm_edge,8,120)
 --right
 spr(bounds.spr_corner,120,120,1,1,true)
 spr(bounds.spr_btm_edge,112,120,1,1,true)
end

function draw_floor()
 map(floor[floor_i],0,0,0,16,16)
 --print(floor_i,64,64,6)
end

-->8
--interactables

--bushes
function init_bushes()
 bushes = {}
 for i = 1, berries_to_collect do
  add_new_bush()
 end
 for bush in all(bushes) do
  bush:init()
  add(game_objects,bush)
 end
end

function update_bushes()
 for bush in all(bushes) do
  bush:update()
 end
end

function add_new_bush()
 add(bushes, {
  x = 18 + rnd(78),--20-96
  y = 10 + rnd(102),--10-112
  sprite = 96, --96 & 98 for anim
  w = 12,
  h =16,
  flipped = false,
  x_offset = 3,
  y_offset = 8,
  col_w = 0,
  col_h = 0,
  anim_time = 0,
  shake_anim = {96,98},
  shake_anim_speed = 0.1,
  debug_color = 7,
  anim_i = 1,
  bar_x = 0,
  bar_y = 0,
  bar_active = false,
  bar_progress = 0,
  bar_max_progress = 0,
  search_progress = 1,
  berries_found = false,
  search_speed = 0.05,
  flash = 0,
  flash_end = false,
  flash_timer = 0,
  flash_y = 0,
  berries_x = {0,0,0},
  berries_y = {0,0,0},
  shadow = true,
  shadow_x = 0,
  shadow_y = 0,
  shadow_w = 15,
  shadow_h = 6,
  sound_on = false,
  highlight = false,
  init = function(self)
   self.col_w = self.w - self.x_offset
   self.col_h = self.h - self.y_offset
   self.shadow_x = self.x
   self.shadow_y = self.y+12
   --random flip just for variety illusion
   local r = flr(rnd(10)) + 1
   if r > 5 then
    self.flipped = false
   else
    self.flipped = true
   end
   --ui bar
   self.bar_x = self.x
   self.bar_y = self.y
   self.bar_progress = self.bar_x+self.x_offset
   self.bar_max_progress = self.bar_x+self.w-1
   --berries positions
   for i=1, #self.berries_x do
    self.berries_x[i] = 3+rnd(10)+self.x
    self.berries_y[i] = 8+rnd(7)+self.y
   end
  end,
  update = function(self)
   if box_hit(self.x+self.x_offset,self.y+self.y_offset,
   self.col_w,self.col_h,
   player.x+player.x_offset,player.y+player.y_offset,
   player.col_w,player.col_h) and not self.berries_found then
    self.debug_color = 8
    --white outline for feedback
    self.highlight = true
    if player.searching and self.berries_found == false
    and not player.dead then
     if not self.sound_on then
      sfx(1,3)
      self.sound_on = true
     end
     if time() - self.anim_time > self.shake_anim_speed then
      self.anim_i = anim_loop(
      self.shake_anim,self,self.anim_i)
      for i = 1, #self.berries_y do
       if self.anim_i == 2 then
        self.berries_y[i]-=1
       else
        self.berries_y[i]+=1
       end
      end
     end
     --activate progression bar for the search
     self.bar_active = true
     self.search_progress+=self.search_speed
     if self.search_progress > self.w-4 then
      self.search_progress = self.w-4
      self.berries_found = true
      player.berries+=1
      sfx(4)
     end
    else
     sfx(-2,3)
     self.sound_on = false
     self.bar_active = false
    end
   else
    if self.bar_active then
     sfx(-2,3)
     self.sound_on = false
     self.bar_active = false
    end
    self.highlight = false
    self.debug_color = 7
    self.sprite = 96
   end
   --feedback
   if self.berries_found and self.flash_end == false then
    self.flash_timer+=1
    self.flash_y-=0.25
    if self.flash_timer > 50 then
     self.flash_end = true
    end
   end
  end,
  draw = function(self)
   --ui feedback
   if self.bar_active then
    rectfill(self.bar_x+self.x_offset,self.bar_y,
    self.bar_x+self.w,self.bar_y+2,1)
    rectfill(self.bar_x+self.x_offset+1,self.bar_y+1,
    self.bar_x+self.w-1,self.bar_y+1,2)
    rectfill(self.bar_x+self.x_offset+1,self.bar_y+1,
    self.bar_progress+self.search_progress,self.bar_y+1,14)
   elseif self.berries_found and self.flash_end == false then
    self.flash+=0.5
    outline_text("+1",self.x+1,--+self.x_offset,
    self.y+4+self.flash_y,1,6+self.flash%2)
    spr(64,self.x+self.x_offset+4,self.y+4+self.flash_y)
   end
   --bush
   --spr(self.sprite, self.x, self.y,2,2,self.flipped)
   outline_sprite(self.sprite,6,self.x,self.y,2,2,
   self.flipped,false,self.highlight)
   --blueberries
   if self.berries_found == false then
    for i = 1, #self.berries_x do
     pset(self.berries_x[i], self.berries_y[i], 14)
    end
   end
   if debug then
    rect(self.x+self.x_offset,self.y+self.y_offset,self.x+self.w,
    self.y+self.h,self.debug_color)
   end
  end
 })
end

--bear traps
function init_traps()
 traps = {}
 traps_generation()
end

function update_traps()
 for trap in all(traps) do
  trap:update()
 end
end

function add_new_trap()
 add(traps, {
  x = 0,
  y = 0,
  sprite = 100, --100, 102
  h = 8,
  col_w = 3,
  col_h = 3,
  x_offset = 6,
  y_offset = 7,
  debug_color = 7,
  init = function(self)
   self.x = 18 + rnd(78)--20-96
   self.y = 10 + rnd(102)--10-112
  end,
  update = function(self)
   if box_hit(self.x+self.x_offset,self.y+self.y_offset,
   self.col_w,self.col_h,
   player.x+player.foot_x_offset,player.y+player.foot_y_offset,
   player.foot_w,player.foot_h) and player.dead == false then
    --kill player
    music(-1, 300)
    sfx(5)
    self.debug_color = 8
    self.sprite = 102
    player.x = self.x
    player.y = self.y - 5
    player.shadow_x = player.x+2
    player.shadow_y = player.y+13
    kid_death_ps(player.x+8,player.y+8,7)
    trap_ps(player.x+8,player.y+8,1)
    self.h = 16
    player.sprite = player.death_anim[1]
    player.dead = true
    player.dead_by_trap = true
    shake = true
    sfx(7)
   else
    self.debug_color = 7
   end
  end,
  draw = function(self)
   spr(self.sprite,self.x,self.y,2,2)
   if debug then
    rect(self.x+self.x_offset,self.y+self.y_offset,
    self.x+self.x_offset+self.col_w,
    self.y+self.y_offset+self.col_h,self.debug_color)
   end
  end,
  check_cols = function(self)
   --check if don't collide with any bushes
   for _bush in all(bushes) do
    if box_hit(self.x+self.x_offset,self.y+self.y_offset,
    self.col_w,self.col_h,
    _bush.x+_bush.x_offset,_bush.y+_bush.y_offset,
    _bush.col_w,_bush.col_h) then
     del(traps,self)
    end
   end
   --check if don't collide with other traps
   for i = 1,#traps-1 do
    if box_hit(self.x+self.x_offset,self.y+self.y_offset,
    self.col_w,self.col_h,
    traps[i].x+traps[i].x_offset,traps[i].y+traps[i].y_offset,
    traps[i].col_w,traps[i].col_h) then
     del(traps,self)
    end
   end
   --check if don't collide with player
   if box_hit(self.x+self.x_offset,self.y+self.y_offset,
   self.col_w,self.col_h,
   player.x+player.foot_x_offset,player.y+player.foot_y_offset,
   player.foot_w,player.foot_h) then
    del(traps,self)
   end
  end
 })
end

--so they don't block bushes or collide with the player or each other
function traps_generation()
 while #traps < traps_in_level do
  add_new_trap()
  traps[count(traps)]:init()
  traps[count(traps)]:check_cols()
 end

 for trap in all(traps) do
  add(game_objects,trap)
 end
end

--squirrels
function init_squirrels()
 squirrels = {}
end

function update_squirrels()
 squirrels_system()
 for squirrel in all(squirrels) do
  squirrel:update()
 end
end

function add_new_squirrel(_side)
 add(squirrels, {
  x = 0, --change depending on side
  y = 8+rnd(106), --8-112
  w = 8,
  h = 8,
  speed = 0, --change depending on side
  current_speed = 0,
  sqrl_timer = 0,
  stop_time = 30+rnd(30), --1-2 seconds
  run_time = 30+rnd(30), --1-2 seconds
  sprite = 68,
  idle_anim = {68,69},
  run_anim = {70,71},
  anim_time = 0,
  anim_i = 0,
  anim_speed = 0.1,
  flipped = false, --change depending on side
  side = _side,
  state = "run",
  angle = 0,
  curvature = 1,
  hunted = false,
  flash_end = false,
  flash_timer = 0,
  flash_y = 0,
  flash = 0,
  shadow = true,
  shadow_x = 0,
  shadow_y = 0,
  shadow_w = 7,
  shadow_h = 3,
  init = function(self)
   self.shadow_x = self.x
   self.shadow_y = self.y+6
   if self.side == "right" then
    self.x = 120
    self.speed = -1.5
    self.current_speed = -1.5
    self.flipped = false
   elseif self.side == "left" then
    self.x = 0
    self.speed = 1.5
    self.current_speed = 1.5
    self.flipped = true
   end
  end,
  update = function(self)
   if not self.hunted then
    self:sqrl_behaviour()

    if time() - self.anim_time > self.anim_speed then
     if self.state == "run" then
      self.anim_i = anim_loop(
      self.run_anim,self,self.anim_i)
     elseif self.state == "idle" then
      self.anim_i = anim_loop(
      self.idle_anim,self,self.anim_i)
     end
    end

    self.x+=self.speed
    self.y += sin(self.angle)*self.curvature
    self.angle += 0.03
    self.shadow_x = self.x
    self.shadow_y = self.y+6

    if self.side == "right" then
     if self.x < 0 then
      del(squirrels,self)
     end
    elseif self.side == "left" then
     if self.x > 120 then
      del(squirrels,self)
     end
    end
   else
    --update flash
    if not self.flash_end then
     self.flash_timer+=1
     self.flash_y-=0.25
     if self.flash_timer > 50 then
      self.flash_end = true
      del(game_objects,_squirrel)
      del(squirrels,self)
     end
    end
   end
  end,
  draw = function(self)
   if not self.hunted then
    spr(self.sprite,self.x,self.y,1,1,self.flipped)
   else
    --flash "+1"
    if not self.flash_end then
     self.flash+=0.5
     spr(65,self.x+4,self.y+4+self.flash_y)
     outline_text("+1",self.x-3,--+self.x_offset,
     self.y+5+self.flash_y,1,6+self.flash%2)
    end
   end

   if debug then
    rect(self.x,self.y,self.x+self.w,self.y+self.h,7)
   end
  end,
  sqrl_behaviour = function(self)
   self.sqrl_timer+=1
   if self.state == "run"
   and self.sqrl_timer >= self.run_time then
    self.state = "idle"
    self.sqrl_timer = 0
    self.speed = 0
    self.curvature = 0
   elseif self.state == "idle"
   and self.sqrl_timer >= self.stop_time then
    self.state = "run"
    self.sqrl_timer = 0
    self.speed = self.current_speed
    self.curvature = 1
   end
  end
 })
end

function squirrels_system()
 --1 squirrel at a time
 if #squirrels < 1 and can_escape == false
 and player.sqrls < sqrls_to_collect then
  local side = flr(rnd(10)) + 1
  if side > 5 then
   add_new_squirrel("left")
  else
   add_new_squirrel("right")
  end
  squirrels[1]:init()
  add(game_objects,squirrels[1])
 end
end

-->8
--ui
function init_ui()
 berries_ui = {}
 berries_ui.x = 8
 berries_ui.y = 2
 berries_ui.white_w = 23
 berries_ui.white_h = 11
 berries_ui.black_w = 23
 berries_ui.black_h = 10

 sqrls_ui = {}
 sqrls_ui.x = 95
 sqrls_ui.y = 2

 escape_flash = 0
 escape_y = 20
 arrow_y = 10
 arrow_spr = 66 --66,67
 arrow_timer = 0
 arrow_anim_time = 0
end

function update_ui()
 if can_escape then
  update_escape_sign()
 end
end

function draw_ui()
 --berries ui
 if berries_to_collect > 0 then
  draw_ui_frames(berries_ui.x,berries_ui.y,berries_ui.white_w,
  berries_ui.white_h,berries_ui.black_w,berries_ui.black_h)
  spr(64,berries_ui.x+2,berries_ui.y+2)
  print(player.berries.."/"..berries_to_collect,
  berries_ui.x+10,berries_ui.y+3,1)
 end
 --squirrels ui
 if sqrls_to_collect > 0 then
  draw_ui_frames(sqrls_ui.x,sqrls_ui.y,berries_ui.white_w,
  berries_ui.white_h,berries_ui.black_w,berries_ui.black_h)
  spr(65,sqrls_ui.x+2,sqrls_ui.y+2)
  print(player.sqrls.."/"..sqrls_to_collect,
  sqrls_ui.x+10,sqrls_ui.y+3,1)
 end

 if can_escape then
  --draw escape sign on top
  draw_escape_sign()
 end
end

function draw_ui_frames(_x,_y,_back_w,_back_h,_front_w,_front_h)
 --back frame
 line(_x,_y+1,_x,_y+_back_h-1,6)
 rectfill(_x+1,_y,_x+_back_w,_y+_back_h,6)
 line(_x+_back_w+1,_y+1,_x+_back_w+1,_y+_back_h-1,6)
 --front frame
 line(_x+2,_y+1,_x+_front_w-1,_y+1,1)
 line(_x+2,_y+_front_h,_x+_front_w-1,_y+_front_h,1)
 line(_x+1,_y+2,_x+1,_y+_front_h-1,1)
 line(_x+_front_w,_y+2,_x+_front_w,_y+_front_h-1,1)
end

function update_escape_sign()
 arrow_timer = time()*2 % 1
 arrow_y = lerp(10,0,arrow_timer)
 if time() - arrow_anim_time > 0.1 then
  arrow_spr+=1
  arrow_anim_time = time()
  if arrow_spr > 67 then
   arrow_spr = 66
  end
 end
end

function draw_escape_sign()
 escape_flash+=0.5
 outline_text("escape",hcenter("escape"),
 escape_y,1,7+escape_flash%2)
 spr(arrow_spr,60,arrow_y)
end

-->8
--bullets
function init_bullets()
 bullets = {}
 bullet_timer = 0
 b_left_x = -8
 b_right_x = 128
 next_spawn_y = 0
 next_spawn_side = 0
 --just test one bullet
 --add_new_bullet("left",b_left_x,rnd(120))
 --for bullet in all(bullets) do
  --bullet:init()
 --end
 init_bullet_warnings()
end

function update_bullets()
 bullets_system()
 update_bullet_warnings()

 for bullet in all(bullets) do
  bullet:update()
 end
end

function draw_bullets()
 draw_bullet_warnings()
 for bullet in all(bullets) do
  bullet:draw()
 end
end

function add_new_bullet(_side,_x,_y)
 add(bullets, {
  x = _x,
  y = _y,
  speed = 0, --change depending on side
  sprite = 80, --80,81,82
  r = 4,
  side = _side,
  anim_time = 0,
  anim_i = 1,
  bullet_anim = {80,81,82},
  anim_speed = 0.01,
  debug_color = 7,
  init = function(self)
   if self.side == "right" then
    --self.x = 128
    self.speed = -1.5
   elseif self.side == "left" then
    --self.x = -8
    self.speed = 1.5
   end
   --self.y = rnd(120)
  end,
  update = function(self)
   --animation
   if time() - self.anim_time > self.anim_speed then
    self.anim_i = anim_loop(
    self.bullet_anim,self,self.anim_i)
   end

   self.x+=self.speed
   if self.side == "right" then
    if self.x < -8 then
     del(bullets,self)
    end
   elseif self.side == "left" then
    if self.x > 128 then
     del(bullets,self)
    end
   end

   if self.y < -4 then
    del(bullets,self)
   end
  end,
  draw = function(self)
   spr(self.sprite,self.x,self.y)
   if debug then
    circ(self.x+self.r,self.y+self.r,self.r,self.debug_color)
   end
  end,
  hitted = function(self)
   del(bullets,self)
   --add particles fx
  end
 })
end

function bullets_system()
 --change patter per level
 if level == 1 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   bullets_normal_pattern(next_spawn_y,next_spawn_side)
   bullet_timer = 0
  end
 elseif level == 2 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 5 then
    bullets_h_pattern(next_spawn_y,next_spawn_side)
   else
    bullets_normal_pattern(next_spawn_y,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 3 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 5 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   else
    bullets_normal_pattern(next_spawn_y,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 4 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 0 and pattern < 3 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   elseif pattern >= 3 and pattern <= 6 then
    bullets_h_pattern(next_spawn_y,next_spawn_side)
   elseif pattern > 6 then
    bullets_normal_pattern(next_spawn_y,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 5 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 5 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   else
    bullets_h_pattern(next_spawn_y,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 6 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 0 and pattern < 3 then
    bullets_triangle_pattern(next_spawn_y-8,next_spawn_side)
   elseif pattern >= 3 and pattern <= 6 then
    bullets_h_pattern(next_spawn_y,next_spawn_side)
   elseif pattern > 6 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 7 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 5 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   else
    bullets_triangle_pattern(next_spawn_y-8,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 8 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 0 and pattern < 3 then
    bullets_diagonal_pattern(next_spawn_y-8,next_spawn_side)
   elseif pattern >= 3 and pattern <= 6 then
    bullets_h_pattern(next_spawn_y,next_spawn_side)
   elseif pattern > 6 then
    bullets_triangle_pattern(next_spawn_y-8,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 9 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 5 then
    bullets_snake_pattern(next_spawn_y,next_spawn_side)
   else
    bullets_diagonal_pattern(next_spawn_y-8,next_spawn_side)
   end
   bullet_timer = 0
  end
 elseif level == 10 then
  bullet_timer+=1
  if bullet_timer == 1 then
   next_spawn_y = rnd(120)
   next_spawn_side = flr(rnd(10)) + 1
   add_new_bullet_warning(next_spawn_y,next_spawn_side)
  end
  if bullet_timer >= b_spawn_rate then
   local pattern = flr(rnd(10)) + 1
   if pattern > 0 and pattern < 2 then
    bullets_triangle_pattern(next_spawn_y-8,next_spawn_side)
   elseif pattern >= 2 and pattern <= 5 then
    bullets_diagonal_pattern(next_spawn_y-8,next_spawn_side)
   elseif pattern > 5 and pattern < 9 then
    bullets_snake_pattern(next_spawn_y,next_spawn_side)
   elseif pattern >= 9 then
    bullets_v_pattern(next_spawn_y-8,next_spawn_side)
   end
   bullet_timer = 0
  end
 end
end

function bullets_normal_pattern(_y,_side)
 if _side > 5 then
  add_new_bullet("left",b_left_x,_y)
 else
  add_new_bullet("right",b_right_x,_y)
 end
 bullets[count(bullets)]:init()
end

function bullets_v_pattern(_y,_side)
 if _side > 5 then
  for i = 0, 2 do
   add_new_bullet("left",b_left_x,_y+(i*8))
   bullets[count(bullets)]:init()
  end
 else
  for i = 0, 2 do
   add_new_bullet("right",b_right_x,_y+(i*8))
   bullets[count(bullets)]:init()
  end
 end
end

function bullets_h_pattern(_y,_side)
 if _side > 5 then
  for i = 0, 2 do
   add_new_bullet("left",b_left_x-(i*8),_y)
   bullets[count(bullets)]:init()
  end
 else
  for i = 0, 2 do
   add_new_bullet("right",b_right_x+(i*8),_y)
   bullets[count(bullets)]:init()
  end
 end
end

function bullets_diagonal_pattern(_y,_side)
 if _side > 5 then
  for i = 0, 2 do
   add_new_bullet("left",b_left_x-(i*8),_y+(i*8))
   bullets[count(bullets)]:init()
  end
 else
  for i = 0, 2 do
   add_new_bullet("right",b_right_x+(i*8),_y+(i*8))
   bullets[count(bullets)]:init()
  end
 end
end

function bullets_triangle_pattern(_y,_side)
 if _side > 5 then
  for i = 0, 2 do
   if i == 1 then
    add_new_bullet("left",b_left_x,_y+(i*8))
   else
    add_new_bullet("left",b_left_x-8,_y+(i*8))
   end
   bullets[count(bullets)]:init()
  end
 else
  for i = 0, 2 do
   if i == 1 then
    add_new_bullet("right",b_right_x,_y+(i*8))
   else
    add_new_bullet("right",b_right_x+8,_y+(i*8))
   end
   bullets[count(bullets)]:init()
  end
 end
end

function bullets_snake_pattern(_y,_side)
 if _side > 5 then
  for i = 0, 3 do
   local _b_y = _y+sin(0.4*i)*2.5
   add_new_bullet("left",b_left_x-(i*8),_b_y)
   bullets[count(bullets)]:init()
  end
 else
  for i = 0, 3 do
   local _b_y = _y+sin(0.4*i)*2.5
   add_new_bullet("right",b_right_x+(i*8),_b_y)
   bullets[count(bullets)]:init()
  end
 end
end

function init_bullet_warnings()
 warnings = {}
end

function update_bullet_warnings()
 for warning in all(warnings) do
  warning:update()
 end
end

function draw_bullet_warnings()
 for warning in all(warnings) do
  warning:draw()
 end
end

function add_new_bullet_warning(_y,_side)
 add(warnings,{
  x = 0,
  y = _y,
  flash = 0,
  lifetime = 30, --1 second
  side = _side,
  init = function(self)
   if self.side > 5 then
    self.x = 3
   else
    self.x = 120
   end
  end,
  draw = function(self)
   self.flash+=0.5
   outline_text("!",self.x,self.y,1,6+self.flash%2)
  end,
  update = function(self)
   self.lifetime -= 1
   if self.lifetime <= 0 then
    del(warnings,self)
   end
  end
 })

 warnings[count(warnings)]:init()
end

-->8
--vfx
function draw_shadows()
 for game_object in all(game_objects) do
  if game_object.shadow then
   ovalfill(game_object.shadow_x,game_object.shadow_y,
   game_object.shadow_x+game_object.shadow_w,
   game_object.shadow_y+game_object.shadow_h,12)
  end
 end
end
--particles system thanks to dylan bennet
function init_particles_system()
 ps={} --empty particle table
 g=0.1 --particle gravity
 max_vel=2 --max initial particle velocity
 min_time=2 --min/max time between particles
 max_time=4
 min_life=15 --particle lifetime
 max_life=25
 t=0 --ticker
 --cols={1,1,1,13,13,12,12,7} --colors
 --burst=50
 sqrl_burst = 60
 kid_burst = 70
 trap_burst = 30
 next_p=rndb(min_time,max_time)
end

function rndb(low,high)
 return flr(rnd(high-low+1)+low)
end

function update_particles()
 --[[
 t+=1
 if t==next_p then
  add_p(64,64)
  next_p=rndb(min_time,max_time)
  t=0
 end
 --burst
 if (btnp(4)) then
  for i=1,burst do add_p(64,64) end
 end
 ]]--
 foreach(ps,update_p)
end

function draw_particles()
  foreach(ps,draw_p)
end

function add_p(x,y,p_color)
 local p={}
 p.x = x
 p.y = y
 p.dx=rnd(max_vel)-max_vel/2
 p.dy=rnd(max_vel)*-1
 p.life_start=rndb(min_life,max_life)
 p.life=p.life_start
 p.color = p_color
 add(ps,p)
end

function update_p(p)
 if p.life<=0 then
  del(ps,p) --kill old particles
 else
  p.dy+=g --add gravity
  --if ((p.y+p.dy)>127) p.dy*=-0.8
  p.x+=p.dx --update position
  p.y+=p.dy
  p.life-=1 --die a little
 end
end

function draw_p(p)
 --local pcol=flr(p.life/p.life_start*#cols+1)
 pset(p.x,p.y,p.color)
end

function sqrl_kill_ps(_x,_y,_color)
 for i=1,sqrl_burst do add_p(_x,_y,_color) end
end

function kid_death_ps(_x,_y,_color)
 for i=1,kid_burst do add_p(_x,_y,_color) end
end

function trap_ps(_x,_y,_color)
 for i=1,trap_burst do add_p(_x,_y,_color) end
end

--smoke effect
function init_smoke_particles()
 s_ps={} --empty particle table
 s_min_time=2
 s_max_time=4
 s_max_vel=1 --max initial particle velocity
 s_min_life=20 --particle lifetime
 s_max_life=30
 s_t=0 --ticker
 s_cols={1,1,2,2,5,5,5,6} --colors
 s_burst=50
 s_next_p=rndb(s_min_time,s_max_time)
end

function update_smoke_particles()
 s_t+=1
 if s_t==s_next_p then
  add_smoke_p(fire.x+8,fire.y+6)
  s_next_p=rndb(s_min_time,s_max_time)
  s_t=0
 end
 foreach(s_ps,update_smoke_p)
end

function update_smoke_p(p)
 if p.life<=0 then
  del(s_ps,p) --kill old particles
 else
  p.dy-=0.02
  p.x+=p.dx --update position
  p.y+=p.dy
  p.life-=1 --die a little
  p.r -= 0.2
 end
end

function draw_smoke_particles()
 foreach(s_ps,draw_smoke_p)
end

function draw_smoke_p(p)
 local pcol=flr(p.life/p.life_start*#s_cols+1)
 circfill(p.x,p.y,p.r,s_cols[pcol])
end

function add_smoke_p(x,y)
 local p={}
 p.x = x
 p.y = y
 p.dx=rnd(s_max_vel)-s_max_vel/2
 p.dy=rnd(s_max_vel)*-1
 p.life_start=rndb(s_min_life,s_max_life)
 p.life=p.life_start
 p.r = 4
 add(s_ps,p)
end









































__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001111100000000000000000000000000000000000000001111100000000000000000000000000000000000000000000001111100000000000000000000
00001117777711000000000111111100000000011111000000117777711100000011111110000000000011111000000000001117777711000000000000000000
00017779999999100000111777779910000011177777100001997777777710000199777771110000000177777111000000017779999999100000000000000000
00017999999991000001777999999100000177799999910000197777777710000019777777771000001977777777100000017999999991000000000000000000
000179fffff7100000017999999910000001799999999910000177777777100000017777777710000199777777771000000179fffff710000000111111110000
00017f1fff171000000179fffff71000000179fffff7110000017777777710000001777777771000001177777777100000017f6fff6710000001777777771000
00017ffffff7100000017f1fff17100000017f1fff17100000017777777710000001777777771000000177777777100000017ffffff710000001777777771000
000017ffff71000000017ffffff7100000017ffffff71000000017777771000000017777777710000001777777771000000017ffff7100000001777777771000
0001777667771000000017ffff710000000017ffff71000000017777777710000000177777710000000017777771000000017776677710000001799999971000
000177766777100000017776677710000001777667771000000177777777100000017777777710000001777777771000001777766777710000017f9999971000
0001f776677f1000001777766777710000017776677710000001f777777f10000017777777777100000177777777100001f1777667771f10000017ff99710000
0000177667710000001f77766777f100001f77766777f1000000177777710000001f77777777f100001f77777777f10000001776677100000001777667771000
00001eeeeee1000000001eeeeee1000000001eeeeee1000000001eeeeee1000000001eeeeee1000000001eeeeee1000000001eeeeee100000001f776677f1000
00001ee11ee1000000001ee11ee1000000001ee11ee1000000001ee11ee1000000001ee11ee1000000001ee11ee1000000001ee11ee100000000177667710000
00001e1001e1000000001e1001e1000000001e1001e1000000001e1001e1000000001e1001e1000000001e1001e1000000001e1001e1000000001ee11ee10000
00000000000000000000000111110000000000000000000000000001111100000000000000000000000011111000000000000000000000000000111110000000
00000001111111000000111777771000000000011111110000001117777710000011111110000000000177777111000000111111100000000001777771110000
00001117777799100001777999999100000011177777991000017779999991000199777771110000001977777777100001997777711100000019777777771000
00017779999991000001799999999910000177799999910000017999999999100019777777771000019977777777100000197777777710000199777777771000
0001799999991000000179fffff711000001799999991000000179fffff711000001777777771000001177777777100000017777777710000011777777771000
000179fffff7100000017f1fff171000000179fffff7100000017f1fff1710000001777777771000000177777777100000017777777710000001777777771000
00017f1fff17100000017ffffff7100000017f1fff17100000017ffffff710000001777777771000000177777777100000017777777710000001777777771000
00017ffffff71000000017ffff71000000017ffffff71000000017ffff7100000001777777771000000017777771000000017777777710000000177777710000
000017ffff7100000001777667771000000017ffff71000000017776677710000000177777710000000177777777100000001777777100000001777777771000
000177766777100000017776677f100000017776677710000001f776677710000001777777771000000177777777100000017777777710000001777777771000
00017776677f100000017776677100000001f7766777100000001776677710000001777777771000000177777777710000017777777710000017777777771000
00017776677100000001f77667710000000017766777100000001776677f10000001777777777100000017777777f1000017777777771000001f777777710000
0001f7766771000000001eeeeee1000000001776677f100000001eeeeee10000000017777777f10000001eeeeee10000001f77777771000000001eeeeee10000
00001eeeeee1000000001e111ee1000000001eeeeee1000000001ee111e1000000001eeeeee1000000001ee111e1000000001eeeeee1000000001e111ee10000
00001e111ee100000000000001e1000000001ee111e1000000001e100000000000001ee111e1000000001e100000000000001e111ee100000000000001e10000
0000000001e100000000000001e1000000001e100000000000001e100000000000001e100000000000001e10000000000000000001e100000000000001e10000
00000000000000000001100000011000000000100000000000000010000000100000000000000000000000000000000000000000000000000000000000000000
00022000080000800018810000166100010101810000001001010181010101810000000000000000000000000000000000000000000000000000000000000000
002ee200088888800188881001666610181818810101018118181881181818810000000000000000000000000000000000000000000000000000000000000000
02ee6e20088888801888888116666661188818811818188118881881188818810000000000000000000000000000000000000000000000000000000000000000
02eeee20081881801118811111166111118188101888188111818810118188100000000000000000000000000000000000000000000000000000000000000000
002ee200088888800018810000166100188881001181881018888100188881000000000000000000000000000000000000000000000000000000000000000000
00022000008888000018810000166100018881001888810001888100018881000000000000000000000000000000000000000000000000000000000000000000
00000000000000000011110000111100018081000180810001800000000081000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c7667c00c7777c00666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c766667cc776677c6666666600000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666cc766667c6666666600005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666cc766667c6666666600555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c766667cc776677c6666666601550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c7667c00c7777c00666666001100000015555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc000066660010000000115550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001000010000000000000000000000660000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000015100151000000011001100110000066000000000000000000000000000000000000000000000000000000000000
00000000000000000000000aaa000000010015100151001000155115511551000006600000000000000000000000000000000000000000000000000000000000
0000000aaa00000000000aaddda00000151155511551015100115111511151000000660000000000000000000000000000000000000000000000000000000000
00000aaddda0000000aaaddddddaa000155511155111155101111111111111100000666000000000000005500000000000000000000000000000000000000000
00aaaddddddaa0000addddaaddddda00151100011000115101110000000011100000066600000000000005550000000000000000000000000000000000000000
0addddaaddddda00addddaddaddddda0110000155100001111100000000001110000006660000000000000555000000000000000000000000000000000000000
addddaddaddddda0adddaadddddddda0110010155101001111100000000001110000000666000000000000055500000000000000000000000000000000000000
adddaadddddddda0aadaddddddaadda0110151155115101111000000000000110000066660000000000005555000000000000000000000000000000000000000
0adaddddddaadda00adaddddddddadda011551011015511000000000000000000066666600000000005555550000000000000000000000000000000000000000
0adaddddddddaddaadddadddddddadda001155155155110000000000000000000666660000000000055555000000000000000000000000000000000000000000
adddadddddddaddaadddddddddaaddda000011111111000000000000000000000666600000000000055550000000000000000000000000000000000000000000
adddddddddaadddaaddddddddddddda0000000000000000000000000000000000666000000000000055500000000000000000000000000000000000000000000
0adddddddddddda00adddddddddddda0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd33333333d3a003333333333333a0033333333d3333a004444444444bb44444444444444444444999999994444444499999999999999444499999949999994
dda3333333ddd3a033333d33333333a033d33333dd3333a0444bbb444bbbb4444444bb444bbb4444999b999949999994999b999999b999944999999999999999
aa33333333aaa3a03333ddd333d333a03dddd333ad33333a44bbbbb44bbbbb4444bbbbb44bb9444499bbb9999999999999bbb9999bbb99944999b99999b99999
3333aaaaa33333a03dd3aaa33ddd333a3adda3333a33333a449bbbbb49bbb9444bbbbbb4499444449bbb99999999b999999bb9999bbbb994499bbb999bbb99b9
aaaa99999aa33a00dddd33333ada333a33aa33d3333d333a4449bbbb449994444bbbbbb444444bb499999999999bb9999999b99999bb999449bbb9999bb99bb9
99999999999aa900adda3dd333a3333a33333dd333dd33a044449bb94444444449bbbb944444bbbb999999bb99bbb9999999999999999994499b99999999bb99
99999999999999003aa33ad3333333a033333aa33dda33a044444994444444444499994444449bb999999bbb999b999949999994999999944999999999999999
9999999999999900333333a333333a00333333333aa33a0044444444444444444444444444444994999999b99999999944444444999999444499999949999994
49999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99955999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99559599000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95555599000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95959559000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99555599000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99995999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000700000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007000000000000000770000000000000077000000000007770000000000000000000000000000000111110000000000011111000000000000000000000
00000007700000000000000770000000000000077700000000000777700000000000000000000000000011777771110000001177777111000000000000000000
00000077700000000000007777000000000000777770000000000077777000000000000000000000000199999997771000019999999777100000000000000000
000000777700000000000077777000000000007777700000000000777777000000000bbbb0000000000019999999971000001999999997100000000000000000
00000777770000000000007777770000000000777777000000000777777700000000bbbbb40000000000017fffff97100000017fffff97100000000000000000
00000777777000000000077777777000000007777777700000000777777770000000bbbb4400000000000171fff1f71000000171fff1f7100000000000000000
0000777777777000000077778777700000007777777770000000777877777000000000bb440000000000017ffffff7100000017ffffff7100000000000000000
00077778777777000007777887777700000077778777770000077778877777000000000bb400000000000017ffff710000000017ffff71000000000000000000
007777788777777000777788887777000000777788777700000777788777770000000000044400000001f7777667771000000177766777100000000000000000
077777888877777000777888888777000000777888777770000777788877770000000000bbb4444400001117766777100001f717766777100000000000000000
07777888887777700077888888887700000777888887777000077788887777700000000bbbbbb4440000cc1776677f100000111776677f100000000000000000
07778888888777700077888888888770007778888887777000777888888777700000000bbbbb0bbb00cccc17766771c000cccc17766771c00000000000000000
077788888888777000778888888887700077788888887770007778888888777000000000bbb00bbb0cccc1ee11ee1ccc0cccc1ee11ee1ccc0000000000000000
0077888888887700007778888888877000077788888877000007778888887700000000000b000bbb00cc1e1cc1e1ccc000cc1e1cc1e1ccc00000000000000000
000778888887700000077788888877000000778888877000000077788887700000000000000000bb0000ccccccccc0000000ccccccccc0000000000000000000
00006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000
00006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000
00006677776666667777666677777777776666777766666677776677777777777766667777777777777766777777777777666600000000000000000000000000
00006677776666667777666677777777776666777766666677776677777777777766667777777777777766777777777777666600000000000000000000000000
00006677772277667777227777772277777766777777776677772277777722777777667777772222222222777777227777776666000000000000000000000000
00006677772277667777227777772277777766777777776677772277777722777777667777772222222222777777227777776666000000000000000000000000
00006677777777777777227777772277777722777777777777772277777722777777227777777777776666777777227777772266000000000000000000000000
00006677777777777777227777772277777722777777777777772277777722777777227777777777776666777777227777772266000000000000000000000000
00006677777777777777227777777777777722777722777777772277777722777777227777772222222266777777777777222266000000000000000000000000
00006677777777777777227777777777777722777722777777772277777722777777227777772222222266777777777777222266000000000000000000000000
00006666777722777722227777772277777722777722662277772277777777777722227777777777777766777777227777776666000000000000000000000000
00006666777722777722227777772277777722777722662277772277777777777722227777777777777766777777227777776666000000000000000000000000
00000066662222662222666622222266222222662222666666222266222222222222666622222222222222662222226622222266000000000000000000000000
00000066662222662222666622222266222222662222666666222266222222222222666622222222222222662222226622222266000000000000000000000000
00000000666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000000000000000000000000
00000000666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000000000000000000000000
00000000000000000000000000000000666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777776677777766777777667777777777776666000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777776677777766777777667777777777776666000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777772222777777227777772277777766660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777772222777777227777772277777766660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777222266777777227777772277777722660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777222266777777227777772277777722660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777776666777777227777772277777722660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777777777776666777777227777772277777722660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777772277777766777777227777777777772222660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000667777772277777766777777227777777777772222660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666622222266222222662222226622222222222266660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666622222266222222662222226622222222222266660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006666666666666666666666666666666666666666000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006666666666666666666666666666666666666666000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000
00000000000000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000
00000000000000778888777777888877778888888888777788887777778888778888888888887777888888888888887788888888888877770000000000000000
00000000000000778888777777888877778888888888777788887777778888778888888888887777888888888888887788888888888877770000000000000000
00000000000000778888118877888811888888118888887788888888778888118888881188888877888888111111111188888811888888777700000000000000
00000000000000778888118877888811888888118888887788888888778888118888881188888877888888111111111188888811888888777700000000000000
00000000000000778888888888888811888888118888881188888888888888118888881188888811888888888888777788888811888888117700000000000000
00000000000000778888888888888811888888118888881188888888888888118888881188888811888888888888777788888811888888117700000000000000
00000000000000778888888888888811888888888888881188881188888888118888881188888811888888111111117788888888888811117700000000000000
00000000000000778888888888888811888888888888881188881188888888118888881188888811888888111111117788888888888811117700000000000000
00000000000000777788881188881111888888118888881188881177118888118888888888881111888888888888887788888811888888777700000000000000
00000000000000777788881188881111888888118888881188881177118888118888888888881111888888888888887788888811888888777700000000000000
00000000000000007777111177111177771111117711111177111177777711117711111111111177771111111111111177111111771111117700000000000000
00000000000000007777111177111177771111117711111177111177777711117711111111111177771111111111111177111111771111117700000000000000
00000000000000000077777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777700000000000000
00000000000000000077777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777700000000000000
00000000000000000000000000000000000000000077777777777777777777777777777777777777770000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077777777777777777777777777777777777777770000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888778888887788888877888888888888777700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888778888887788888877888888888888777700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888888111188888811888888118888887777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888888111188888811888888118888887777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888811117788888811888888118888881177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888811117788888811888888118888881177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888888777788888811888888118888881177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888888888777788888811888888118888881177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888118888887788888811888888888888111177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077888888118888887788888811888888888888111177000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077771111117711111177111111771111111111117777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077771111117711111177111111771111111111117777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000777777777777777777777777777777777777777700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000777777777777777777777777777777777777777700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006001000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000666000000011100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006666600000001000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006666666000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000106666666600000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000688866600000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000068888600000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000667888880000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000ggg677888888gggggggggg00888880000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000ggggggggggggg678888888ggggggggg0ggggggg8880gggggggg0000000000000000000000000000000000000000
000000000000000000000000000000ggggggggggggggggggggg788888888ggggggggg0gggggggg80ggggggggggggggg000000000000000000000000000000000
0000000000000000000000000gggggggggggggggggggggggggg888988888gggggggggg08vvvvvg80gggggggggggggggggggg0000000000000000000000000000
0000000000000000000000gggggggggggggggggggggggggggg88889988888ggggggggg080vvv0v80ggggggggggggggggggggggg0000000000000000000000000
0000000000000000000ggggggggggggggggggggggggggggggg88889988888ggggggggg08vvvvvv80gggggggggggggggggggggggggg0000000000000000000000
00000000000000000gggggggggggggggggggggggggggkkkkgg88889998888gkkkkggggg08vvvv80ggggggggggggggggggggggggggggg00000000000000000000
000000000000000ggggggggggggggggggggggggggggkkkkk4g888999988884kkkkkggg0888778880gggggggggggggggggggggggggggggg000000000000000000
00000000000000gggggggggggggggggggggggggggggkkkk4488899999988844kkkkg0v8088778880ggggggggggggggggggggggggggggggg00000000000000000
0000000000000ggggggggggggggggggggggggggggggggkk4488899999998844kkgggg000887788v0gggggggggggggggggggggggggggggggg0000000000000000
0000000000000gggggggggggggggggggggggggggggggggkk4g888999999884kkgggllll08877880lgggggggggggggggggggggggggggggggg0000000000000000
0000000000000ggggggggggggggggggggggggggggggggggg44488899998444ggggllll0ss00ss0lllggggggggggggggggggggggggggggggg0000000000000000
00000000000000gggggggggggggggggggggggggggggggggkkk4444444444kkkggggll0s0ll0s0lllggggggggggggggggggggggggggggggg00000000000000000
000000000000000gggggggggggggggggggggggggggggggkkkkkk444444kkkkkkggggglllllllllgggggggggggggggggggggggggggggggg000000000000000000
00000000000000000gggggggggggggggggggggggggggggkkkkkgkkkkkkgkkkkkgggggggggggggggggggggggggggggggggggggggggggg00000000000000000000
0000000000000000000ggggggggggggggggggggggggggggkkkggkkkkkkggkkkggggggggggggggggggggggggggggggggggggggggggg0000000000000000000000
0000000000000000000000ggggggggggggggggggggggggggkgggkkkkkkgggkggggggggggggggggggggggggggggggggggggggggg0000000000000000000000000
0000000000000000000000000ggggggggggggggggggggggggggggkkkkggggggggggggggggggggggggggggggggggggggggggg0000000000000000000000000000
000000000000000000000000000000ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg000000000000000000000000000000000
0000000000000000000000000000000000000ggggggggggggggggggggggggggggggggggggggggggggggggggg0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000ggggggggggggggggggggggggggggggg00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077777000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000077077007770077007700000770707700000777007700000077070000770707000000000000000000000000000000000
00000000000000000000000000000000707070707700700070000000777077700000070070700000707070007070777000000000000000000000000000000000
00000000000000000000000000000000777077007000007000700000770707700000070070700000777070007770007000000000000000000000000000000000
00000000000000000000000000000000700070700770770077000000077777000000070077000000700007707070770000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj000j0j0jjjjjj0jj000j0j0j0j0j00jjjjjj000j0jjjj00jj00jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj0j0j0j0jjjjj0j0jj0jj0j0j0j0j0j0jjjjj0j0j0jjj0jjj0j0jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj00jj000jjjjj0j0jj0jj0j0j000j0j0jjjjj000j0jjj0jjj0j0jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj0j0jjj0jjjjj0jjjj0jj000jjj0j0j0jjjjj0j0j0jjj0j0j0j0jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj000j000jjjjjj00j000jj0jjjj0j0j0j000j0j0j000j000j00jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj

__map__
0000860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000088000000000000000000890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000890000000000008600000000000000000000900000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000088000000000000000000000000000088890000000000000000000000000000008700000000000000000000000000008f000000000000000000000000000000000000000000000000000000000000000086000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000890000000000000000000000000000008600000000000000000000000000000000000000900000000000000000000000008b000000000000000000000086000000900000008e8a8a8a8a00
000000008900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008f000000000000000000000000000000000000000000000000898c87000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000086000000008f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008600000000000000000000000000000000000000000000000000
0000000000008e8a8a8d0000000000000000000000008700000000000000000000000000008b000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000086000000000000000000000000000000008b00000000000000000000000000008900009000000000000000
000000000000008c00000000000000000000000000000000000000000000000000000000008a8d0000000000000000000000000000000000000000000000000000000000000000880090000000000000000000000000000000000000880000000000000000008a00000000000000000000000000000000000000000000000000
000000000000000000008600000000000000000000000000000000000000000000000000008a00000000000000000000000000000000000000008900000000000000000000000000000000000000000000000000008e8a8a8a8d0000000000000000008f878e8a8a8a8a8d000000000000000000000000000000000000000000
0000000000000000000000000000000000008f0000000000000000000000000000000000008c0000008e8a8d00000000000000000000008700000000000000000000000000000000000000008600000000000000000000008a890000000000000000000000008a00000000000000000000000000009000000090000000000000
000000000000000000000000000000000000000000008900008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000008f00000000000000000000000000008c000000000000000000000000008a00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008e8a8d000000000000000000000000000000000000000000000000000000000000000000000000000000008600008c00000000000000000000000000000000870000000000000000
000000000087000000008b000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000008a00000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000
000000000000000000008c000000000000000000000000000090000000000000000000000000000000000000000000000000000000008900008a8d00000000000000000000000088000000000000000000000090000000000000880000000000000000000000000000000000000000000000008800000000008b000000000000
0000000000000000000000000000000000000000890000000000000000000000000000000000000000000000000000000000000000000000008c00000000000000000000000000000000008f0000000000000000000000860000000000000000000000000000000000000000000000000000000000008600008a000000000000
000000000000000089000000000000000000000000000000000000000000000000000000000000868700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000008a000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000095000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0c1c2c3c4c5c6c7c8c9cacbcc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0d1d2d3d4d5d6d7d8d9dadbdc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000e4e5e6e7e8e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000f4f5f6f7f8f900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001e8701e8701e870208701d870168700f870078700287002870398003a8003a8003b8003b8003b8003b8003b8003a800398003780034800318002f8002d8002c8002ef0022f0018f000ff000000000000
0005000b1d11019110151100e1100c1101011018110161100f1101c1101f110000000000000000000000000000000000000000001000060000000000000000000000000000000000000000000000000000000000
0001000005620096200c6200e620116201362014620126200a6200762008620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000263402b3402f34025340173400c3400434000340053400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000000000000305702e570295602456020560175501455012550155502754035540335402f530255301d530265202852029520285202551022510205102e5102f5102f510165100f5100b5100751002510
00020000366703f670396703067023670126700766004660016600366000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000c7700e7700c770117700e770137701077015770107701577011760177601576010760137600e760157600e75015750107501775015750137400c740137401074015720107201772010710157100c710
000a0000113700e37015370173700c3701037013360173600e3600c360133500e35011350153501135017340103401334011340103300c33017330153100c3101131017310003000030000300003000030000000
000600000c5701557017570155700e57013570155700e57013570155700c5700e56013560155600e5601355015550135500c55017540155400e540135400c530155300e530135200c520175200e5101351017510
01100020175550c555175550e55515555135551155515555185551a5551f5551d5551f5551d5551a5551f5551f555215551f55518555135550c555175551d555185551f55513555105551f5551d5551c55515555
01100000050500005007050020500905002050070500205009050040500b0500905002050070500005009050020500b050020500905004050070500205009050040500b050020500905000050020500205002050
__music__
03 090a4944
03 0a424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 00424344
