pos = {x=0.0,y=0.0,z=0.0,dir=0} --dir=0 north 1=east 2=south 3=west, x=+north/-south y=+east/-west
posSafe ={x=0,y=0,z=0,dir=0}

torchtmp=0 --How long the turtle moved without placing torch
torchDis=0
ntnl=0
tnlDeep=0

local function init()
  print("How far should i place the Torches?")
  torchDis=tonumber(io.read())
  
  print("How Many tunnels should i create?")
  ntnl=tonumber(io.read())
  
  print("How deep should be each tunnel?")
  tnlDeep=tonumber(io.read())
end
  


local function safeForward() --moves forward even in cause of Gravel
  while not(turtle.forward()) do
    turtle.dig()
    sleep(0.3)
  end
  if pos.dir==0 then
    pos.x=pos.x+1
  elseif pos.dir==1 then
    pos.y=pos.y+1
  elseif pos.dir==2 then
    pos.x=pos.x-1
  elseif pos.dir==3 then
    pos.y=pos.y-1
  end
end

local function safeUp()
  while not(turtle.up()) do
    turtle.digUp()
    sleep(0.3)
  end
  pos.z=pos.z+1
end

local function safeDown()
  while not(turtle.down()) do
    turtle.digDown()
    sleep(0.3)
  end
  pos.z=pos.z-1
end

local function turn(times,dir) --dir=1 turn to right, dir=0turn to Left
  for i=1,times,1 do
    if dir==1 then
      turtle.turnRight()
      if pos.dir==3 then
        pos.dir=0
      else 
        pos.dir=pos.dir+1
      end
    elseif dir==0 then
      turtle.turnLeft()
      if pos.dir==0 then
        pos.dir=3
      else 
        pos.dir=pos.dir-1
      end
    end
  end
end
	
local function digAround() --dig in forward, up and down
  turtle.dig()
  turtle.digUp()
  turtle.digDown()
end

local function getItemSlot(itemName)
  for i=1,16,1 do
    turtle.select(i)
    item = turtle.getItemDetail()
    if not(item==nil) then
      if item.name == itemName then
        return i
      end
    end  
  end
  return 0
end



local function turnToDir(newDir)
  while pos.dir~=newDir do
    turn(1,1)
  end 
end

local function goToZPos(newZ)
  if pos.z>newZ then   
    repeat
      safeDown()
    until pos.z==newZ
  elseif pos.z<newZ then
    repeat
      safeUp()
    until pos.z==newZ 
  end
end

local function goToYPos(newY)   --Move back to Home
  if pos.y>newY then   
    repeat
      turn(1,0)
    until pos.dir==3  
  elseif pos.y<newY then
    repeat
      turn(1,1)
    until pos.dir==1 
  end
  while pos.y~=newY do
    safeForward()
  end
end
    
local function goToXPos(newX)
  if pos.x>newX then   
    repeat
      turn(1,0)
    until pos.dir==2  
  elseif pos.x<newX then
    repeat
      turn(1,1)
    until pos.dir==0 
  end
  while pos.x~=newX do
    safeForward()
  end
end

local function unload() 
  posSafe.x=pos.x   --safe current Posiotion
  posSafe.y=pos.y
  posSafe.z=pos.z
  posSafe.dir=pos.dir
  
  goToYPos(0)
  goToXPos(0)
  goToZPos(0)
  turnToDir(2)
  
  bo,a,err = turtle.inspect()                   --Empty inventory
  while not(a.name=="minecraft:chest") do
    print("Please place a chest for items")
    sleep(5)
  end
  
  for i=2,16,1 do
    turtle.select(i)
    if not(turtle.getItemCount(i)==0) then
      if not(turtle.drop()) then
        print("Please empty the chest")
        while not(turtle.drop()) do
          sleep(5) 
        end
      end
    end
  end
  
  safeUp()
  bo,a,err = turtle.inspect()                   --Get Torches
  while not(a.name=="minecraft:chest") do
    print("Please place a chest witch Torches")
    sleep(5)
  end
  turtle.select(1)
  turtle.suck(32)
  while getItemSlot("minecraft:torch")==0 do
    turtle.select(1)
    sleep(5)
    turtle.suck(32)
    print("Please refill Torches")
  end
  
  if turtle.getFuelLevel()<300 then
    safeUp()
    bo,a,err = turtle.inspect()                   --Get Torches
    while not(a.name=="minecraft:chest") do
      print("Please place a chest witch Fuel")
      sleep(5)
    end
    turtle.select(16)
    turtle.suck(1)
    turtle.refuel()
    while turtle.getFuelLevel()<300 do
      turtle.select(16)
      turtle.suck(1)
      turtle.refuel()
      sleep(5)
      print("less fuel")
    end
    safeDown()
  end
  
  goToZPos(posSafe.z)
  goToXPos(posSafe.x)
  goToYPos(posSafe.y)
  turnToDir(posSafe.dir) 
end

local function setTorchUp()
  y = getItemSlot ("minecraft:torch")
  if y==0 then
    unload()
    y = getItemSlot()
  end
  turtle.placeUp()
end

local function checkFull() --checkt if the inventory is full
  y = turtle.getItemCount(16)
  if y~=0 then
    unload()
  else 
   return false
 end 
end

local function digStep(times)
  for i=1,times,1 do
    safeForward()
    checkFull()
    digAround()
  end
end

local function toNextStrip()
  turnToDir(0)
  digStep(1)
  torchtmp=torchtmp+2
  turn(1,0)
  digStep(2)
  turn(1,1)
  digStep(1)
  turn(1,1)
  digStep(2)
  turn(1,0)
  if torchtmp>torchDis then
    setTorchUp()
    torchtmp=0
  end
  safeForward()
end

local function nextStrip()
  turnToDir(1)
  digStep(tnlDeep)
  setTorchUp()
  turnToDir(3)
  digStep(((tnlDeep*2)+2))
  setTorchUp()
  goToYPos(0)
end

local function main()
  print("Beginne")
  unload()
  safeUp()
  for j=1,ntnl,1 do
    toNextStrip()
    nextStrip()
  end
  goToYPos(0)
  goToXPos(0)
  goToZPos(0)
end

init()
main()
