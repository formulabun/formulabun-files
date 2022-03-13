-- Written by Fl_GUI with no intention of sharing it. If you want to use this
-- go ahead but I'm not obliged to help you with this in any way.

local PATH = "character_finishes.cfg";
local data = {};
local doOnce = false;

local file = io.open(PATH, "r");
if file then
  for l in file:lines() do
    local characterText, countText = string.match(l, "(%a+) (%d+)");
    data[characterText] = tonumber(countText);
  end;
  file:close();
else
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

addHook("ThinkFrame", function()
  for p in players.iterate do
    if not (p.valid and p.mo) then continue end;
    if p.exiting == 199 then -- player just finished, add one to count
      if consoleplayer != server and p != consoleplayer then continue end; -- only keep console player stats if consoleplayer
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
