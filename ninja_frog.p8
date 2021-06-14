pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--fly eater
--by ivan almanza
--game loop❎🅾️
debug = false
game_start = false
game_over = false
function _init()
 palt(12, true) -- blue color as transparency is true
 palt(0, false) -- black color as transparency is false
 music(0)
 title_x = 32
 title_y = 16
 init_background()

 init_game()
end

function _update()
 update_background()
 if game_start == false then
  update_menu()
 elseif game_over == false
 and game_start == true then
  update_game()
 elseif game_over == true then
  update_game_over()
 end
end

function _draw()
 cls(12)
 draw_background()
 if game_start == false then
  draw_menu()
 elseif game_over == false
 and game_start == true then
  draw_game()
 elseif game_over == true then
  draw_game_over()
 end
end

function draw_title()
 spr(136,title_x,title_y,4,4)
 spr(140,title_x+32,title_y,4,4)
 spr(192,title_x-32,title_y+32,4,4)
 spr(196,title_x,title_y+32,4,4)
 spr(200,title_x+32,title_y+32,4,4)
 spr(204,title_x+64,title_y+32,4,4)
end

function update_menu()
 if btnp(5) and game_start == false then
  game_start = true
 end
end

function draw_menu()
 --draw title here
 draw_title()
 --rectfill(32,10,32+64,10+64,8)
 play_text = "❎ PLAY "
 write_text(play_text,hcenter(play_text),90,0)

 rectfill(0,120,128,128,8)
 --credits = "BY @IV4N_ALGO"
 credits = "by @iv4n_algo"
 print(credits,hcenter(credits),121,7)
end

function init_game()
 make_frog()

 init_flies()
 add_new_fly()

 init_floor()
 --add_floor(0)
 for i=0,8 do
  add_floor(i*16)
 end
 init_energy_bar()
end

function update_game()
 update_frog()

 update_flies()

 --update_floor()

 update_energy_bar()
end

function draw_game()
 --[[
 for tile in all(floors) do
  tile:draw()
 end
--]]
 for fly in all(flies) do
  fly:draw()
 end
 draw_frog()
 draw_energy_bar()
 draw_score()
end

function update_game_over()
 if btnp(5) then
  restart_game()
 elseif btnp(4) then
  go_to_menu()
 end
end

function draw_game_over()
 game_over_text = "game over!"
 write_text(game_over_text,hcenter(game_over_text),50,0)
 score_text = "score:"..score
 write_text(score_text,hcenter(score_text),70,0)
 menu_text = "🅾️ MENU "
 write_text(menu_text,hcenter(menu_text),85,0)
 replay_text = "❎ PLAY AGAIN "
 write_text(replay_text,hcenter(replay_text),95,0)
end

function restart_game()
 init_game()
 game_start = true
 game_over = false
end

function go_to_menu()
 init_game()
 game_over = false
 game_start = false
end
--function to center text
function hcenter(s)
  -- screen center minus the
  -- string length times the
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end

-->8
--frog script
function make_frog()
 frog = {}
 frog.sprite = 0 --0 - 10: body sprites
 frog.x = 24 --position
	frog.y = 96
	frog.dy = 0 --fall speed
	frog.speed = 2 --run speed
	frog.score = 0
 frog.anim_time = 0 --to control anim speed
 frog.run_anim_speed = 0.05
 --frog head
 frog.head = {}
 frog.head.x = frog.x
 frog.head.y = frog.y - 14
 frog.head.sprite = 32 --32 - 42: head sprites
 --frog tongue
 frog.tongue = {}
 frog.tongue.x0 = frog.head.x + 14
 frog.tongue.y0 = frog.head.y + 12
 frog.tongue.x1 = frog.tongue.x0 + 50
 frog.tongue.y1 = frog.tongue.y0
 frog.tongue.w = 2
 frog.tongue.h = 2
 frog.tongue.catch = false

 tongue_x_limit = frog.tongue.x1
 tongue_y_limit = frog.tongue.y1
 frog.tongue.x1 = frog.tongue.x0
 tongue_speed = 0.5
 y0_corrections = {frog.head.y + 12, frog.head.y + 10,
                   frog.head.y + 9, frog.head.y + 8,
                   frog.head.y + 7, frog.head.y + 6}

 y1_corrections = {frog.head.y + 12, frog.head.y + 4,
                   frog.head.y - 4, frog.head.y - 12,
                   frog.head.y - 20, frog.head.y - 28}
 score = 0
end

function update_frog()
 if time() - frog.anim_time > frog.run_anim_speed then
  frog.sprite += 2
  frog.anim_time = time()
  if frog.sprite > 10 then
   frog.sprite = 0
  end
  sync_head()
 end
 head_rotation()
 --if frog.tongue.catch == false then
 tongue_ctrl()
 --end
 sync_tongue()
end

function draw_frog()
 spr(frog.sprite, frog.x, frog.y, 2, 2)
 if(tongue_attack) then
  line(frog.tongue.x0, frog.tongue.y0,
  frog.tongue.x1, frog.tongue.y1, 14)
  circfill(frog.tongue.x1, frog.tongue.y1, 1, 14)
 end
 spr(frog.head.sprite, frog.head.x, frog.head.y, 2, 2)
 if debug == true then
  rect(frog.tongue.x1-1,frog.tongue.y1-1,
       frog.tongue.x1+frog.tongue.w-1,
       frog.tongue.y1+frog.tongue.h-1,8)
  print("tongue X limit reached: "
  ..(xlimit_reached and 'true' or 'false'),
  0, 0, 7)
  print("tongue x limit: "..tongue_x_limit, 0, 6, 7)
  print("tongue x: "..frog.tongue.x1, 0, 12, 7)
 end
end

function sync_head()
 if frog.sprite == 2 or frog.sprite == 8 then
  frog.head.y += 1
  for i = 1, #y0_corrections do
   y0_corrections[i] += 1
  end
 else
  if frog.head.y > frog.y - 14 then
   frog.head.y -= 1
   for i = 1, #y0_corrections do
    y0_corrections[i] -= 1
   end
  end
 end
end

function sync_tongue()
 if frog.head.sprite == 32 then
  frog.tongue.y0 = y0_corrections[1]
  tongue_y_limit = y1_corrections[1]
 elseif frog.head.sprite == 34 then
  frog.tongue.y0 = y0_corrections[2]
  tongue_y_limit = y1_corrections[2]
 elseif frog.head.sprite == 36 then
  frog.tongue.y0 = y0_corrections[3]
  tongue_y_limit = y1_corrections[3]
 elseif frog.head.sprite == 38 then
  frog.tongue.y0 = y0_corrections[4]
  tongue_y_limit = y1_corrections[4]
 elseif frog.head.sprite == 40 then
  frog.tongue.y0 = y0_corrections[5]
  tongue_y_limit = y1_corrections[5]
 elseif frog.head.sprite == 42 then
  frog.tongue.y0 = y0_corrections[6]
  tongue_y_limit = y1_corrections[6]
 end
end

function head_rotation()
 if btn(2) then --up
  if frog.head.sprite < 42 then
   frog.head.sprite += 2
  end
 end
 if btn(3) then --down
  if frog.head.sprite >= 34 then
   frog.head.sprite -= 2
  end
 end
end

function tongue_ctrl()
 if btn(5)
 and xlimit_reached == false then
  tongue_speed = 0.5
  tongue_attack = true
  --X increment
  if frog.tongue.x1 < tongue_x_limit then
   --frog.tongue.x1 += tongue_speed
   frog.tongue.x1 = lerp(frog.tongue.x1,tongue_x_limit,tongue_speed)
   --tongue_collision_x(frog.tongue.x1)
  end
  if frog.tongue.x1 >= tongue_x_limit - 0.5 then
   frog.tongue.x1 = tongue_x_limit
   xlimit_reached = true
  end
  --Y increment
  if frog.tongue.y1 > tongue_y_limit then
   --frog.tongue.y1 -= (tongue_speed - 5)
   frog.tongue.y1 = lerp(frog.tongue.y1,tongue_y_limit,tongue_speed)
   --tongue_collision_y(frog.tongue.y1)
  end
  if frog.tongue.y1 <= tongue_y_limit then
   frog.tongue.y1 = tongue_y_limit
   --ylimit_reached = true
  end
  tongue_collision_x(frog.tongue.x1)
  tongue_collision_y(frog.tongue.y1)
 else
  --X decrement
  if xlimit_reached == true
  or frog.tongue.x1 > frog.tongue.x0 then--frog.tongue.x1 > frog.tongue.x0 then
   --frog.tongue.x1 -= tongue_speed
   frog.tongue.x1 = lerp(frog.tongue.x1,frog.tongue.x0,tongue_speed)
  end
  if frog.tongue.x1 <= frog.tongue.x0 + 0.1 then
   frog.tongue.x1 = frog.tongue.x0
   tongue_attack = false
   tongue_speed = 0
   xlimit_reached = false
  end
  --Y decrement
  if frog.tongue.y1 < frog.tongue.y0 then
   --frog.tongue.y1 += (tongue_speed - 4)
   frog.tongue.y1 = lerp(frog.tongue.y1,frog.tongue.y0,tongue_speed)
  end
  if frog.tongue.y1 >= frog.tongue.y0 then
   frog.tongue.y1 = frog.tongue.y0
   --ylimit_reached = false
  end
 end
end

function box_hit(x1,y1,w1,h1,x2,y2,w2,h2)
 hit = false
 if x1 < x2 + w2 and x1 + w1 > x2 and
    y1 < y2 + h2 and y1 + h1 > y2 then
   hit = true
 end
 return hit
end

function tongue_collision_x(x)
 for new_x = x,lerp(frog.tongue.x1,tongue_x_limit,tongue_speed) do
  for fly in all(flies) do
   if box_hit(new_x-1,frog.tongue.y1-1,frog.tongue.w-1,
                  frog.tongue.h-1,fly.x,fly.y+2,fly.w,fly.h)
   and new_x <= tongue_x_limit then
       sfx(2)
       fly.dead = true
       frog.tongue.catch = true
       frog.tongue.x1 = new_x
   end
  end
 end
end

function tongue_collision_y(y)
 for new_y = y,lerp(frog.tongue.y1,tongue_y_limit,tongue_speed),-1 do
  for fly in all(flies) do
   if box_hit(frog.tongue.x1-1,new_y-1,frog.tongue.w-1,
                  frog.tongue.h-1,fly.x,fly.y+2,fly.w,fly.h)
   and new_y >= tongue_y_limit then
       sfx(2)
       fly.dead = true
       frog.tongue.catch = true
       frog.tongue.y1 = new_y
   end
  end
 end
end

--lerp function thanks to DEMO_MAN tutorials
function lerp(A, B, t)
 return A+(B-A)*t;
end

--hud stuff
--energy meter
function init_energy_bar()
 energy = 0 --0 is full, 30 is empty
 energy_fill = 10 + energy
end

function update_energy_bar()
 energy += 0.05
 energy_fill = 10 + energy
 if energy_fill >= 40 then
  energy_fill = 40
  game_over = true
 end
end

function draw_energy_bar()
 rectfill(6,10,10,40,8)
 rectfill(6,energy_fill,10,40,10)
 spr(67,5,1)
 spr(82,5,9)
 spr(81,5,17)
 spr(81,5,25)
 spr(80,5,33)
end
--score text
function draw_score()
 write_text("score:"..score,88,5,0)
end

function write_text(text,x,y,c)
 box_x = x-1
 box_y = y-1
 rectfill(box_x,box_y,box_x+#text*4,box_y+6,7)
 line(box_x,box_y+7,box_x+#text*4,box_y+7,6)
 print(text,x,y,c)
end

-->8
--flies
function init_flies()
 flies = {}
 flies_timer = 0
end

function update_flies()
 flies_timer+=1
 if flies_timer == 90 then --every 3 seconds spawn fly
  add_new_fly()
  flies_timer = 0 -- reset timer
 end

 for fly in all(flies) do
  fly:update()
  fly:movement()
 end
end

function add_new_fly()
  add(flies, {
   x = 134,
   y = 50 + rnd(50),-- a random number between 36 and 99
   angle = 0,
   speed = 1,
   curvature = 1 + rnd(4),
   sprite = 64,
   w = 6,
   h = 4,
   dead = false,
   update = function(self)
    self.sprite += 1
    if(self.sprite > 66) then
     self.sprite = 64
    end
    --self.movement()
   end,
   draw = function(self)
    spr(self.sprite, self.x, self.y)
    if debug == true then
     rect(self.x,self.y+2,self.x+self.w,self.y+self.h+2,8)
    end
   end,
   movement = function(self)
    if self.dead == false then
     self.x -= self.speed
     self.y += sin(self.angle)*self.curvature
     self.angle += 0.03
     if(self.x < -10) then
      del(flies, self)
     end
    else
     self.x = frog.tongue.x1 - 3
     self.y = frog.tongue.y1 - 3
     if self.x == frog.tongue.x0 - 3 then
      score += 1
      energy -= 3.5
      if energy < 0 then
       energy = 0
      end
      del(flies, self)
      add_new_fly()
     end
    end
   end
  })
end
-->8
--floor
function init_floor()
 floors = {}
end

function add_floor(_x)
 add(floors, {
  x = _x,
  y= 112,
  speed = 2,
  spr_random_index = flr(rnd(4)) + 1,
  sprite = {96,98,100,102},
  update = function(self)
   self.x -= self.speed
   if self.x <= -16 then
    add_floor(floors[count(floors)].x + 16)
    del(floors, self)
   end
  end,
  draw = function(self)
   spr(self.sprite[self.spr_random_index], self.x, self.y, 2, 2)
  end
 })
end

function update_floor()
 for tile in all(floors) do
  tile:update()
 end
end

--background
function init_background()
 layer01_x = 0
 layer02_x = 0
 clouds_x = 0
 layer01_speed = 0.75
 layer02_speed = 0.5
 clouds_speed = 0.25
end

function update_background()
 if game_over == false then
  update_floor()

  layer01_x -= layer01_speed
  if layer01_x < -127 then
   layer01_x = 0
  end
  layer02_x -= layer02_speed
  if layer02_x < -127 then
   layer02_x = 0
  end
  clouds_x -= clouds_speed
  if clouds_x < -127 then
   clouds_x = 0
  end
 end
end

function draw_background()
 map(32,0,clouds_x,0,16,16)
 map(32,0,clouds_x+128,0,16,16)
 map(0,0,layer02_x,0,16,16)
 map(0,0,layer02_x+128,0,16,16)
 map(16,0,layer01_x,0,16,16)
 map(16,0,layer01_x+128,0,16,16)

 for tile in all(floors) do
  tile:draw()
 end
end




































__gfx__
b00000000000ccccccccccccccccccccb00000000000ccccb00000000000ccccccccccccccccccccb00000000000cccccccccccccccccccccccccccccccccccc
cbccc0000000ccccb00000000000cccccbccc0000000cccccbccc0000000ccccb00000000000cccccbccc0000000cccccccccccccccccccccccccccccccccccc
ccccccc00000cccccbccc0000000ccccccccccc00000ccccccccccc00000cccccbccc0000000ccccccccccc00000cccccccccccccccccccccccccccccccccccc
ccccccc0000cccccccccccc00000ccccccccccc0000cccccccccccc0000cccccccccccc00000ccccccccccc0000ccccccccccccccccccccccccccccccccccccc
cccccc00000cccccccccccc0000ccccccccccc00000ccccccccccc00000cccccccccccc0000ccccccccccc00000ccccccccccccccccccccccccccccccccccccc
cccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccccccccccccccccccccccccccccc
ccccc000000ccccccccccc00000cccccccccc000000cccccccccc000000ccccccccccc00000cccccccccc000000ccccccccccccccccccccccccccccccccccccc
ccccc888888ccccccccccc00000cccccccccc888888cccccccccc888888ccccccccccc00000cccccccccc888888ccccccccccccccccccccccccccccccccccccc
ccccc888888ccccccccccc88888cccccccccc888888cccccccccc888888ccccccccccc88888cccccccccc888888ccccccccccccccccccccccccccccccccccccc
ccccc000000ccccccccccc88888cccccccccc10000000cccccccc100000ccccccccccc88888cccccccccc00000111ccccccccccccccccccccccccccccccccccc
cccc0000001cccccccccccc0000cccccccccc110000000cccccc1111000cccccccccccc0000cccccccccc000011111cccccccccccccccccccccccccccccccccc
cbbb000cc111ccccccccccc0000ccccccccc111cccccc0cccbbb111cc000ccccccccccc1000ccccccccc000cccccc1cccccccccccccccccccccccccccccccccc
cbcccccccc111cccccccbbb000ccccccccc111cccccccbcccbcccccccc000cccccccbbb100ccccccccc000cccccccbcccccccccccccccccccccccccccccccccc
cbcccccccccc1cccccccbccc1cccccccccb11ccccccccbbbcbcccccccccc0cccccccbccc0cccccccccb00ccccccccbbbcccccccccccccccccccccccccccccccc
ccccccccccccbcccccccbcccbcccccccccbcccccccccccccccccccccccccbcccccccbcccbcccccccccbccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccbbbcccccccccbbbcccccccbbccccccccccccccccccccccccbbbcccccccccbbbcccccccbbcccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaccccccccccccaaaaccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaacccccccccccaa000ccccccccaaaaa000cccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc8aacccccccccccc8aaacccccccccaaaa000cccccccaaaaaaaacccccccaa000aaaacccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccc8aaa8aaaacccccccaaa8aaaaaccccccaaaaaaaaaccccccaa000aaaacccccc8aaaaaaaaacccccccccccccccccccccccccccccccccccc
ccc8c8aaa88aaccccc8c8aaaaaa000cccc8caaaaaaa000ccc8caaa000aaaaccccc8aaaaaaaabbcccc8baaaaaabbbb3cccccccccccccccccccccccccccccccccc
cccc8aaaaaaaaaccccc8ba000aaaaaccccc8aa000aaaaacccc8aaaaaaaaacccc888baaaaabbbbb3c88bbaaaabbbb3ccccccccccccccccccccccccccccccccccc
ccc8ba000aa000cccc8bbaaaaabaaccccc8baaaaabaaacccc8bbaaaaabbbbb3cc8bbbaaabbbb33ccc8bbbbbbb333bccccccccccccccccccccccccccccccccccc
ccccbaaaaaaaaacccccbbbaaabbbbbcccccbbaaabbbbbb3ccccbbaaabbbb33cc8ccbbbbbb333bccc8cbbbbbbbbbbbccccccccccccccccccccccccccccccccccc
ccccbbaaabbaacccccccbbbb3bbb33ccccccbbbbb33333cccccbbbbbb333bccccccbbbbbbbbbbccccccbbbbbbbbbcccccccccccccccccccccccccccccccccccc
ccccbbbb3bbbbbccccccbbbbb333bcccccccbbbbbbbbbcccccccbbbbbbbbccccccccbbbbbbbbccccccccbbbbbbbbcccccccccccccccccccccccccccccccccccc
cccccbbbb33333cccccccbbbbbbbcccccccccbbbbbbbcccccccccbbbbbbbcccccccccbbbbbbbcccccccccbbbbbbccccccccccccccccccccccccccccccccccccc
ccccccbbbbbbccccccccccbbbbbcccccccccccbbbbbcccccccccccbbbbbcccccccccccbbbbbcccccccccccbbbbbccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc09a0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc777cccccccccccccccccccc09a90cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc0077cccc00777ccc000ccccc09aa0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc800ccccc80777ccc8077cccc09aa90cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0000cccc0000cccc000777cccc00a90cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc09aa90cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc09a990ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc07c777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc0777000077cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
70cccc0770cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7700007770cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c777777c70cccc0770cccc07cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
1111111111111111111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
4444444444444444444444444444444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
4111141444414444444444444444444444141111144444444444444444444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc76cccc
4444444444444444441111414111111444444444444444444114411111111441ccc766cccccccccccccccccccccccccccccccccccccccccccc766cccc7776ccc
4444444444444444444444444444444444444441111114114444444444444444cc77776ccccccccccccccccc766cccccc77766cccc766cccc77776cc777776cc
4414444111114144414444111444441111414444444444444111111114411144c7777776c66cccccccc766c77776cccc7777776cc77776cc77777677777776cc
4444444444444444444444444444444444444444444444444444444444444444c77777766776ccccc77777677776cccc777777677777776c7777767777776ccc
1111111111111111111111111111111111111111111111111111111111111111c7777776777766cc7777777677776cccc77776777777776c7777677777667ccc
cccccc2222cccccccccccc2222cccccccccccc2222cccccccccccc2222cccccccc7777677776776c77777776766776ccc777777667777777c7777777777776cc
cccccc1111cccccccccccc1111cccccccccccc1111cccccccccccc1111ccccccccc777cc7777776c777777776776776ccc7777677777777cc77777667777776c
cccccc1111cccccccccccc1111cccccccccccc1111cccccccccccc1111ccccccccccccccc77777cc777777777777776ccccc777777777cccc77776776777776c
cccccc1111cccccccccccc1111cccccccccccc1111cccccccccccc1111ccccccccccccccccccccccc7777777777776cccccccccccccccccccc7777776777776c
ccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccccccccccccccc777ccc7777ccccccccccccccccccccccc7777777776cc
ccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777ccc
ccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccddddddcccccccccc999999cccccdddddddd99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccddddddddcccccccc99999999ccccdddddddd99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccddddddddddcccccc9999999999cccdddddddd99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccddddddddddddcccc999999999999ccdddddddd99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cddddddddddddddcc99999999999999cdddddddd99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddd9999999999999999dddddddd99999999ccccccccccccccccc888cccccccccccccccc888888cccc88ccccccccccc8888c8ccccccc888ccccc
dddddddddddddddd9999999999999999dddddddd99999999cccccccccccccccc800088888888888888880000008888008ccccccccc800888088ccc880088888c
dddddddddddddddd9999999999999999dddddddd99999999cccccccccccccccc800000000888888800000000000000008ccccccccc800000088ccc8800000088
dddddddddddddddd9999999999999999cccccccccccccccccccccccccccccccc800000000000000000000000000000008ccccccccc800000088ccc8800000088
dddddddddddddddd9999999999999999cccccccccccccccccccccccccccccccc880000000000000000000008800000008cccccccccc80000088cccc880000088
dddddddddddddddd9999999999999999cccccccccccccccccccccccccccccccc880000000000000000000008800000008cccccccccc8000008ccccc88000008c
cddddddddddddddcc99999999999999ccccccccccccccccccccccccccccccccc880000000000000000000008800000008cccccccccc8000008ccccc88000008c
ccddddddddddddcccc999999999999cccccccccccccccccccccccccccccccccc88000000000000000000000880000008ccccccccccc8000008ccccc88000008c
cccddddddddddcccccc9999999999ccccccccccccccccccccccccccccccccccc80000000000000000000000880000008ccccccccccc8000008ccccc88000008c
ccccddddddddcccccccc99999999cccccccccccccccccccccccccccccccccccc80088800000000888800000080000008ccccccccccc8000008cccccc8000008c
cccccddddddcccccccccc999999ccccccccccccccccccccccccccccccccccccc88888800000008888800000088000008ccccccccccc8000008888888800008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88c8800000008888808880088000008ccccccccccc8800008888888000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000088888008c8888000008ccccccccccc8800000000000000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000088800008ccc88000008ccccccccccc8800000000000000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000000000088ccc88000008ccccccccccc8800000000000000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000000000088ccc88000008ccccccccccc8800000000000000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000000000088ccc88000088ccccccccccc8800000000000000008cc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000000000088ccc88000088cccccc88c8880000000000000000008c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8800000088888008ccc88000088cccc880080080000888888800000008c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008c888888ccc88000088cccc880000080088888888888000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008ccccccccccc88000088ccccc80000088800088888888000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008ccccccccccc8000008888888800008cc800000888888000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008ccccccccccc8000000088888000008ccc80000000888000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008ccccccccccc8000000000000000008ccc80000000000000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc880000008ccccccccccc8000000000000000008ccc80000000000000008c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc800000000accccccccca0000000000000000008ccc8000000000000008cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc800000000aacccccccca00000000aaa00000000aca000000aaaaaaaaaccc
cccccccccccccccccccccccccaaacccccccc800aaaa00aaccccccaaa000aaaaaaaaaaaa0000aca000aaaaaaaaaaacccccccaaacccccccccccccccccccccccccc
cccccccccccccccccccccccca000aaaaaaaaa000a00aaaaaaaaaa00a00aaaaaaaaaa000a000aaaaaaaa000a00aaaaaaaaaa000accccccccccccccccccccccccc
cccccccccccccccccccccccca000000aaa000000a000000aaa00000a0000aaaaaaa0000a000000aa000000a000000aaa000000accccccccccccccccccccccccc
cccccccccccccccccccccccca00000000000000aaa0000000000000a000000000000000a00000000000000aa00000000000000accccccccccccccccccccccccc
ccccccccccccccccccccccccca0000000000000aaa000000000000aaa0000000000000aa00000000000000aa0000000000000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca0000000000000aaa000000000000aaa0000000000000aa00000000000000aa0000000000000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca00000aaaaa0000a0000000000000aaa0000000000000aa00000aaaaa0000a00000aaaa00000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca00000aaaaaaaaaaaaa000aaa0000aaa000aa000aa000aa000000aaaa00aaaa0000aaaaaa000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca000000000000aacaa0000aaaa0000aa000aa000aa000aa000000000000aaaa0000000000000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca00000000000aaccca000000000000aa000aa000aa000aa00000000000aacaa0000000000000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca00000000000aaccca000000000000a00000a000aa0000a00000000000aacaa0000000000000aaccccccccccccccccccccccccc
ccccccccccccccccccccccccca000000000000accca000000000000a00a00a000aaaaa0a000000000000aaaa000000000aaaaacccccccccccccccccccccccccc
ccccccccccccccccccccccccca00000aaaaaaaaaaa0000aaaa00000aaacaa00000acccaa00000aaaaaaaaaaa0000aa000aaaaaaacccccccccccccccccccccccc
ccccccccccccccccccccccccca00000aaaaaa000aa0000aaaaaa0000accca00000acccca000000aaaaa000aa0000aa00000a000acccccccccccccccccccccccc
ccccccccccccccccccccccccca00000000000000aa0000acccaa0000accca00000acccca00000000000000aa0000aa00000000accccccccccccccccccccccccc
cccccccccccccccccccccccca00000000000000aaa0000acccaa0000accaa000000accaa00000000000000a00000acaaa00000accccccccccccccccccccccccc
cccccccccccccccccccccccca00000000000000aa000000accaa0000aacaa000000accaa00000000000000a00000aacaa00000accccccccccccccccccccccccc
cccccccccccccccccccccccca00aaaaaaaaa0000a0aaa00accaa0aa0aacaa0aaa00accaa0aaaaaaaaa0000a00aa0aaccca00000acccccccccccccccccccccccc
cccccccccccccccccccccccccaacccccccccaaaacaaaaaacccccaaaacccccaaaaaacccccaaaaaaaaaaaaaacaaaaaccccccaaaaaacccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc766cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc766c77776ccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777677776ccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777677776cccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccddddddddddddddccccccccccccccccccccccccccccccccccccccccc77777776766776ccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccddddddddddddddddcccccccccccccccccccccccccccccccccccccccc777777776776776cccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccddddddddddddddddddccccccccccccccccccccccccccccccccccccccc777777777777776cccccc
ccccccccccccccccccccccccccccccccccccccccccccc766cddddddddddddddddddddccccccccc766ccccccccccccccccccccccccccc7777777777776ccccccc
cccccccccccccccccccccccccccccccccccccccccccc7777ddddddddddddddddddddddccccccc77776cccccccccccccccccccccccccccc777ccc7777cccccccc
ccccccccccccccccccccccccccccccccc888ccccccc7777ddddd888888dddd88dddddddcccc88887876c66cc888ccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc800088888888888888880000008888008ddddddccc800888088677880088888ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc800000000888888800000000000000008ddddddccc8000000887778800000088cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc800000000000000000000000000000008ddddddccc8000000887778800000088cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc880000000000000000000008800000008ddddddcccc800000887777880000088cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc880000000000000000000008800000008ddddddcccc8000008cc77788000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc880000000000000000000008800000008ddddddcccc8000008ccccc88000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc88000000000000000000000880000008dddddddcccc8000008ccccc88000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc80000000000000000000000880000008dddddddcccc8000008ccccc88000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc80088800000000888800000080000008dddddddcccc8000008cccccc8000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc88888800000008888800000088000008dddddddcccc8000008888888800008cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc88c8800000008888808880088000008dddddddcccc8800008888888000008cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc8800000088888008d8888000008dddddddcccc8800000000000000008cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc8800000088800008ddd88000008dddddddcccc8800000000000000008cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc8800000000000088ddd88000008dddddddcccc8800000000000000008cccccccccccccccccccccccccccccccccc
cccc77766cccc766ccccccccccccccccccccc8800000000000088ddd88000008dddddddcccc8800000000000000008cccccccccccccccccccccccccccccccccc
ccc7777776cc77776cccccccccccccccccccc8800000000000088ddd88000088dddddddcccc8800000000000000008cccccccccccccccccccccccccccccccccc
ccc777777677777776ccccccccccccccccccc8800000000000088ddd88000088dddddd88c8880000000000000000008ccccccccccccccccccccccccccccccccc
cccc77776777777776ccccccccccccccccccc8800000088888008ddd88000088dddd880080080000888888800000008ccccccccccccccccccccccccccccccccc
cccc777777667777777cccccccccccccccccc880000008c888888ddd88000088dddd880000080088888888888000008ccccccccccccccccccccccccccccccccc
ccccc7777677777777cccccccccccccccccc880000008ccddddddddd88000088ddddd80000088800088888888000008ccccccccccccccccccccccccccccccccc
ccccccc777777777cccccccccccccccccccc880000008ccddddddddd8000008888888800008cc800000888888000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc880000008ccddddddddd8000000088888000008ccc80000000888000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc880000008ccddddddddd8000000000000000008ccc80000000000000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc880000008ccddddddddd8000000000000000008ccc80000000000000008ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc800000000acdddddddda0000000000000000008ccc8000000000000008cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc800000000aadddddddda00000000aaa00000000aca000000aaaaaaaaaccccccccccccccccccccccccccccccccccc
ddcccccccccccccccccccccccaaacccccccc800aaaa00aaddddddaaa000aaaaaaaaaaaa0000aca000aaaaaaaaaaacccccccaaaccccccccccccccdddddddddddd
dddccccccccccccccccccccca000aaaaaaaaa000a00aaaaaaaaaa00a00aaaaaaaaaa000a000aaaaaaaa000a00aaaaaaaaaa000accccccccccccddddddddddddd
ddddcccccccccccccccccccca000000aaa000000a000000aaa00000a0000aaaaaaa0000a000000aa000000a000000aaa000000acccccccccccdddddddddddddd
dddddccccccccccccccccccca00000000000000aaa0000000000000a000000000000000a00000000000000aa00000000000000accccccccccddddddddddddddd
ddddddccccccccccccccccccca0000000000000aaa000000000000aaa0000000000000aa00000000000000aa0000000000000aacccccccccdddddddddddddddd
dddddddcccccccccccccccccca0000000000000aaa000000000000aaa0000000000000aa00000000000000aa0000000000000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca00000aaaaa0000a0000000000000aaa0000000000000aa00000aaaaa0000a00000aaaa00000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca00000aaaaaaaaaaaaa000aaa0000aaa000aa000aa000aa000000aaaa00aaaa0000aaaaaa000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca000000000000aacaa0000aaaa0000aa000aa000aa000aa000000000000aaaa0000000000000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca00000000000aaccca000000000000aa000aa000aa000aa00000000000aacaa0000000000000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca00000000000aaccca000000000000a00000a000aa0000a00000000000aacaa0000000000000aaccccccccddddddddddddddddd
dddddddcccccccccccccccccca000000000000accca000000000000a00a00a000aaaaa0a000000000000aaaa000000000aaaaacccccccccddddddddddddddddd
dddddddcccccccccccccccccca00000aaaaaaaaaaa0000aaaa00000aaadaa00000adddaa00000aaaaaaaaaaa0000aa000aaaaaaacccccccddddddddddddddddd
dddddddcccccccccccccccccca00000aaaaaa000aa0000aaaaaa0000addda00000adddda000000aaaaa000aa0000aa00000a000acccccccddddddddddddddddd
dddddddcccccccccccccccccca00000000000000aa0000adddaa0000addda00000adddda00000000000000aa0000aa00000000accccccccddddddddddddddddd
dddddddccccccccccccccccca00000000000000aaa0000adddaa0000addaa000000addaa00000000000000a00000acaaa00000accccccccddddddddddddddddd
dddddddccccccccccccccccca00000000000000aa000000addaa0000aadaa000000addaa00000000000000a00000aacaa00000accccccccddddddddddddddddd
dddddddccccccccccccccccca00aaaaaaaaa0000a0aaa00addaa0aa0aadaa0aaa00addaa0aaaaaaaaa0000a00aa0aaccca00000acccccccddddddddddddddddd
dddddddccccccccccccccccccaacccccccccaaaacaaaaaadddddaaaadddddaaaaaaddddcaaaaaaaaaaaaaacaaaaaccccccaaaaaacccccccddddddddddddddddd
dddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddd
dddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddd
dddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddd
dddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddd
dddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccddddddddddddddddd
dddddddcccccddddddddddddddcccccccccccccccccccccddddddddddddddddddddddddcccccddddddddddddddddddddddcccccccccccccddddddddddddddddd
dddddddccccddddddddddddddddccccccccccccccccccccddddddddddddddddddddddddccccddddddddddddddddddddddddccccccccccccddddddddddddddddd
dddddddcccddddddddddddddddddcccccccccccccccccccddddddddddddddddddddddddcccddddddddddddddddddddddddddcccccccccccddddddddddddddddd
dddddddccddddddddddddddddddddccccccccccccccccccddddddddddddddddddddddddccddddddddddddddddddddddddddddccccccccccddddddddddddddddd
dddddddcddddddddddddddddddddddcccccccccccccccccddddddddddddddddddddddddcddddddddddddddddddddddddddddddcccccccccddddddddddddddddd
dddddddddddddddddddddddddddddddccccccccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddccccccccddddddddddddddddd
dddddddddddddddddddddddddddddddccccccccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddccccccccddddddddddddddddd
dddddddddddddddddddddddddddddddccccccccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddccccccccddddddddddddddddd
ddddddddddddddd9999999999999999999999ccccccccccdddddddddddddddddddddddd99999999999999ddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddd999999999999999999999999cccccccccddddddddddddddddddddddd9999999999999999dddddddddddddddddddddddddddddddddddddddddd
ddddddddddddd99999999999999999999999999ccccccccdddddddddddddddddddddd999999999999999999ddddddddddddddddddddddddddddddddddddddddd
dddddddddddd9999999999999999999999999999cccccccddddddddddddddddddddd99999999999999999999dddddddddddddddddddddddddddddddddddddddd
ddddddddddd999999999999999999999999999999ccccccdddddddddddddddddddd9999999999999999999999ddddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999cccccddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999cccccddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999cccccddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999cccccddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dccccdd77777777777777777777777777777999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddcccdd77000007777777777777777777777999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddccdd70070700777777007077770070707999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddddcdd70007000777770707077707070007999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddddddd70070700777770007077700077707999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddddddd77000007777770777700707070077999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddddddd77777777777777777777777777777999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999ddddddd66666666666666666666666666666999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
dddddddddd99999999999999999999999999999999dddddddddddddddddddddddd999999999999999999999999dddddddddddddddddddddddddddddddddddddd
999999999999999999999999999999999999999999999ddddddddddddddddddddd999999999999999999999999ddddddddddddddddddddd99999999999999999
9999999999999999999999999999999999999999999999dddddddddddddddddddd999999999999999999999999dddddddddddddddddddd999999999999999999
99999999999999999999999999999999999999999999999ddddddddddddddddddd999999999999999999999999ddddddddddddddddddd9999999999999999999
999999999999999999999999999999999999999999999999dddddddddddddddddd999999999999999999999999dddddddddddddddddd99999999999999999999
9999999999999999999999999999999999999999999999999ddddddddddddddddd999999999999999999999999ddddddddddddddddd999999999999999999999
99999999999999999999999999999999999999999999999999dddddddddddddddd999999999999999999999999dddddddddddddddd9999999999999999999999
99999999999999999999999999999999999999999999999999dddddddddddddddd999999999999999999999999dddddddddddddddd9999999999999999999999
99999999999999999999999999999999999999999999999999dddddddddddddddd999999999999999999999999dddddddddddddddd9999999999999999999999
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44441411111444444441111414444144444444444444444444444444444444444441111414444144444444444444444444411114144441444441111414444144
41444444444444444444444444444444444411114141111114441111414111111444444444444444444411114141111114444444444444444444444444444444
44444444411111141144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44114144444444444444144441111141444144441114444411414444111444441144144441111141444144441114444411441444411111414444144441111141
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
99999999222299999999999922229999999999992222999999999ddd222299999999999922229999999999992222ddddddddddd9222299999999999922229999
999999991111999999999999111199999999999911119999999999dd111199999999999911119999999999991111dddddddddd99111199999999999911119999
9999999911119999999999991111999999999999111199999999999d111199999999999911119999999999991111ddddddddd999111199999999999911119999
99999999111199999999999911119999999999991111999999999999111199999999999911119999999999991111dddddddd9999111199999999999911119999
9999999991199999999999999119999999999999911999999999999991199999999999999119999999999999911dddddddd99999911999999999999991199999
9999999991199999999999999119999999999999911999999999999991199999999999999119999999999999911ddddddd999999911999999999999991199999
9999999991199999999999999119999999999999911999999999999991199999999999999119999999999999911ddddddd999999911999999999999991199999
9999999991199999999999999119999999999999911999999999999991199999999999999119999999999999911ddddddd999999911999999999999991199999

__map__
4848484848484848484848484848484848484848484848489494949494949494868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
484848484848484848484848484848484848484848484848949494949494949486868686866a6b8686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
484848484880848148484848484848484848484848484848949494949494949486686986867a7b8686868686866e6f860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848484848848484484848484848484848484848484848489494949494949494867879868686868686868686867e7f860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
969696484884848448484848484848484848484848484848949494949494949486868686868686866c6d8686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
969696484884848448484848484848484848484848484848949494949494949486868686868686867c7d8686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9696969696848484484848484880848148484848484848489494949494949494868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9696969696848484484848484884848448484848484848489494949494949494868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9548484848848484484848484884848448484848484848489494949494949494868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8084819448848484808484814884848448484848484848489494949494949494868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484849494848484848484848484848485834848484848488285858394949482868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848081848484848484848484848485854848484848488585858594949485868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848485854848484848488585858594949485868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848485854848828585858585858583949485868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848485854848858585858585858585948285868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848485854882858585858585858585838585868686868686868686868686868686860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110002013013332110d01303113100730d043080430d043130130d0430d04303143100730d0432724512221130130d0430d04303143100730d043120430d043130130d0430d04303143100730d0432724533211
0010000013013332110d01303113100730d043080430d043130130d0430d04303143100730d0432724512221130130d0430d04303143100730d043120430d043130130d0430d04303143100730d0432724533211
000100003e6503b6203863034650316502d6402a6502763025620216501e6301b630186101663013650106500d6500a65007650036500065000650006500d6000c6000b6000a6000860007600066000560004600
00100000130000d0000d00003100100000d000120000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000230500d0000d00003100100000d0002720033200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 01424344

