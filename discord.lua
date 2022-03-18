-- Written by Fl_GUI#5136. Do whatever you want with this but let me now.

local message;

addHook("PlayerMsg",
  function(p_from, type, p_target, msg)
    if(type != 0) then return end;
    local i = msg:find("!discord");
    if( i == 1 ) then
      message = "\141<Bun> Go to \132discord.formulabun.club\141 to join our discord!\128", true;
    end;
end);

local function chatprintOnce()
  if( not message) then return end;
  chatprint(message);
  message = nil;
end;

-- happens like one frame later
addHook("ThinkFrame", chatprintOnce)
