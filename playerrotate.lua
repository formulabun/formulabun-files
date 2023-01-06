local doOnce = true

local function countPlayers()
  local result = 0
  for p in players.iterate
  do
    if p and p.valid then
      result = $0+1
    end
  end
  return result
end

local function laterThan(player1, player2) 
  if player1.kartstuff[k_position] == player2.kartstuff[k_position] then
    return player1.score > player2.score
  end
  return player1.kartstuff[k_position] < player2.kartstuff[k_position]
end

local function lastPlayer()
  local last = 1
  for p in players.iterate
  do
    if p and p.valid and not p.spectator then
      if not (players[last] and players[last].valid) then
        last = #p
      elseif laterThan(players[last], p) then
        last = #p
      end
    end
  end
  return last
end

local function inter() 
  if not doOnce then
    return
  end
  doOnce = false

  local cap = CV_FindVar("ingamecap").value
  if cap == 0 or cap >= countPlayers() then
    return 
  end

  players[lastPlayer()].spectator = true
end

local function mapLoad()
  doOnce = true
end

addHook("IntermissionThinker", inter)
addHook("MapLoad", mapLoad)
