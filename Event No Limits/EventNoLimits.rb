# ************************************************************************** #
#                                                                            #
#  EventNoLimits - EventNoLimits.rb                                          #
#                                                                            #
#  Author: Phoenixnoir                                                       #
#                                                                            #
#  Contributor:                                                              #
#                                                                            #
#  Created: 2025-04-01 - 18:32:54                                            #
#  Updated: 2025-04-01 - 18:32:54                                            #
#                                                                            #
#  Description:                                                              #
#  This script removes the event limit per map in RPG Maker XP.              #
#                                                                            #
#  Link: https://github.com/phoenixnoirdev/RpgMakerXp_Asset                  #
#                                                                            #
# ************************************************************************** #

class Game_Map
  alias old_setup setup
  def setup(map_id)
    old_setup(map_id)
    @events = {}
    @map.events.each do |id, event|
      @events[id] = Game_Event.new(@map_id, event)
    end
  end
end
