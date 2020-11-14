levels = {}
levels.sequence = require "levels/sequence"
levels.current_level = 1

function levels.require_current_level()
   local level_filename = "levels/" .. levels.sequence[ levels.current_level ]
   local level = require ( level_filename )
   return level
end

return levels