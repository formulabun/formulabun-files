local PATH = "characterFinishes.cfg";
local data = {};
local doOnce = false;

local file = io.open(PATH, "r");
if file then 
  print("file exists");
  for l in file:lines() do
    local characterText, countText = string.match(l, "(%a+) (%d+)");
    data[characterText] = tonumber(countText);
  end;
  file:close();
else
  print("file doesn't exist");
  file = assert(io.open(PATH, "w"));
  if file then
    file:close();
  else
    print("Couldn't create luafile, permission error maybe?");
  end
end

local function writeFile() 
  file = assert(io.open(PATH, "w"));
  if not file then
    print("Couldn't write to file. Perhaps race condition.");
    return;
  end;

  for char, count in pairs(data) do
    file:write(char.." "..count.."\n");
  end;
  file:close();
end;


COM_AddCommand("debug", function(player) 
  print(player.mo.skin);
end);

addHook("ThinkFrame", function()
  for p in players.iterate do
    if not (p.valid and p.mo) then continue end;
    if p.exiting == 199 then -- player just finished, add one to count
      local skin = p.mo.skin;
      data[skin] = (data[skin] or 0) + 1;
    end;
  end;
end);

addHook("IntermissionThinker", function() 
  if doOnce then return end;
  doOnce = true;
  writeFile();
end);

addHook("MapChange", function()
  doOnce = false;
end);
