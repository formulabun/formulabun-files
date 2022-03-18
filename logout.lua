-- Small command written by Fl_GUI. Use for whatever

COM_AddCommand(
  "logout",
  function(player)
    if(IsPlayerAdmin(player)) then
      COM_BufInsertText(server, "demote "..#player);
    end;
  end
  )
