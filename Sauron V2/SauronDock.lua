-- this file:
-- refuels and empties turtles
-- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronDock")

-- host docking rednet