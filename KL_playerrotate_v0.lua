local doOnce = true

COM_AddCommand("debug", function()
  for p in players.iterate do
    if p and p.valid then
      print("player: "..#p..", health: "..p.health)
    end
  end
end)

local function countPlayers()
  local result = 0
  for p in players.iterate do
    if p and p.valid then
      result = result+1
    end
  end
  return result
end

local function laterThan(player1, player2) 
  if player1.health == player2.health and player1.realtime == player2.realtime then -- a tie
    return player1.score > player2.score
  end
  return player1.realtime < player2.realtime and player1.health >= player2.health
end

local function lastPlayer()
  local last = players[1]
  for p in players.iterate do
    if p and p.valid and not p.spectator then
      if not (last and last.valid) then
        last = p
      elseif laterThan(last, p) then
        last = p
      end
    end
  end
  return last
end

local function removePlayer(player)
  -- skill issue
  CONS_Printf(player, "\x82You were moved to spectator because you are last.\x80")
  CONS_Printf(player, "\x82Remember to join again to not miss your next chance to not lose.\x80")
  player.spectator = true
end

local function inter() 
  if not doOnce then return end
  doOnce = false

  local cap = CV_FindVar("ingamecap").value
  if cap == 0 or cap >= countPlayers() then
    return 
  end

  for p in players.iterate do
    if p and p.valid and p.spectator and p.pflags & PF_WANTSTOJOIN then
      removePlayer(lastPlayer())
      return
    end
  end
end

local function mapLoad()
  doOnce = true
end

addHook("IntermissionThinker", inter)
addHook("MapLoad", mapLoad)
