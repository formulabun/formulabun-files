local bumperhud = "gametypeinfo";
local pointSubtract = 1;
local jointime = nil;

-- Net vars
local enabled = false;
local currentTol = TOL_RACE
local previousMapTol = TOL_RACE

local cvar_enable = CV_RegisterVar({
    name = "nobumpers",
    defaultvalue = 0,
    flags = CV_NETVAR,
    PossibleValue = CV_OnOff,
    func = function(var)
      if (not var.value) then hud.enabled(bumperhud) end;
    end
});

local function setJoinTime()
  if (jointime == nil and leveltime ~= 0) then jointime = leveltime end
  if (leveltime == 1) then jointime = 1 end;
end

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
  if (leveltime ~= jointime) then return end;
  enabled = isEnabled();
end;

local function setPrevMap()
  if (leveltime ~= jointime) then return end

  previousMapTol = currentTol;
  currentTol = maptol;
end

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

local function doHud()
  if (leveltime ~= jointime) then return end;
  if (not enabled) then return end;
  if (previousMapTol == TOL_RACE and currentTol == TOL_RACE)  then return end; -- nothing to do
  if (currentTol == TOL_MATCH) then hud.disable(bumperhud) end;
  if (previousMapTol == TOL_MATCH and currentTol == TOL_RACE) then hud.enable(bumperhud)  end;
end

local function bumperAndScoreLogic() 
  if (not enabled) then return end;

  setWanted()
  for p in players.iterate do
    if (p == nil or p.mo == nil) then continue end;

    -- in case player stole one
    if (p.kartstuff[k_bumper] >= 3) then
      p.kartstuff[k_bumper] = 3;
    end

    -- player lost a bumper
    if (p.kartstuff[k_bumper] < 3) then
      p.kartstuff[k_bumper] = 3;
      subtractPoints(p);
    end;

  end;
end;

local function netVars(n)
  enabled = n(enabled);
  previousMapTol = n(previousMapTol);
  if (enabled) then
    doHud();
  end
end

addHook("ThinkFrame", setEnabled);
addHook("MobjThinker", hideBumpers, MT_BATTLEBUMPER);
addHook("ThinkFrame", setJoinTime);
addHook("ThinkFrame", bumperAndScoreLogic);
addHook("ThinkFrame", setPrevMap);
addHook("ThinkFrame", doHud);
addHook("NetVars", netVars);
