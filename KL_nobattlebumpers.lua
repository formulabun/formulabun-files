local bumperhud = "gametypeinfo";
local enabled = false;
local pointSubtract = 1;

local cvar_enable = CV_RegisterVar({
    name= "nobumpers",
    defaultvalue= 0,
    flags= CV_NETVAR,
    PossibleValue= CV_OnOff,
});

local function subtractPoints(player)
  if (player.marescore < pointSubtract) then
    player.marescore = 0;
  else
    player.marescore = $ - pointSubtract;
  end;
end;

local function isEnabled()
  if (not G_BattleGametype()) then return false end;
  if (not cvar_enable.value) then return false end;

  local hm_timelimit = CV_FindVar("hm_timelimit");
  if (not hm_timelimit) then
    return false;
  end;
  return hm_timelimit.value > 0; 
end;

local function setEnabled()
  enabled = isEnabled();
end;

local function hideBumpers(obj) 
  if (not enabled) then return end;

  obj.sprite = SPR_NULL;
  return true;
end

local function setWanted()
  local maxScore = 0;
  local playerScore;
  for p in players.iterate do
    if (p == nil or p.mo == nil) then continue end;
    playerScore = p.marescore;
    maxScore = (maxScore > playerScore) and maxScore or playerScore
  end

  local wantedScore = 1000;
  for p in players.iterate do
    if (p == nil or p.mo == nil) then continue end;
    if (p.marescore == maxScore) then
      p.kartstuff[k_wanted] = wantedScore;
      wantedScore = $ - 1;
    else
      p.kartstuff[k_wanted] = 0;
    end;
  end
end

local function bumperAndScoreLogic() 
  if (not enabled) then hud.enable(bumperhud) ; return end;

  hud.disable(bumperhud);
  setWanted()
  for p in players.iterate do
    if (p == nil or p.mo == nil) then continue end;

    COM_BufInsertText(p, "echo "..p.kartstuff[k_wanted]);

    -- in case player stole one
    if (p.kartstuff[k_bumper] >= 3) then
      p.kartstuff[k_bumper] = 3;
    end

    -- player lost a bumper
    if (p.kartstuff[k_bumper] == 2) then
      p.kartstuff[k_bumper] = 3;
      subtractPoints(p);
    end;

  end;
end;

addHook("MapLoad", setEnabled);
addHook("MobjThinker", hideBumpers, MT_BATTLEBUMPER);
addHook("ThinkFrame", bumperAndScoreLogic);
