module SYMPHONY
  module View
    # Set this to false to set Battle View to Empty.
    # All Sprites of actors as well as Icon (Weapon, Item...) will be hide.
    # All other Symphony Tags are still available.    
    EMPTY_VIEW = false
    
    # Set Party default Direction. For Number of Direction, check NumPad on the
    # Keyboard. Troop Direction will be opposited with Party Direction.
    PARTY_DIRECTION = 4
    
    # Set Party default Location. If You have more than 4 Actors in Battle, You
    # have to add more index in the hash below.
    # For example: If you have 5 Actors, You will have to add default Location
    # for 5th Actor by adding: 4 => [Location X, Location Y], 
    # (Don't forget the comma at the end of each line)
    ACTORS_POSITION = { # Begin.
      0 =>  [480, 224],
      1 =>  [428, 244],
      2 =>  [472, 264],
      3 =>  [422, 244],
      4 =>  [452, 284],
    } # End.
  end # View
  module Visual
    # Set this to false to disable Weapon Icon creating for non-charset Battlers.
    # Recommend not to enable this, unless You use a Battler which doesn't show
    # its own weapon in the Battler-set.
    WEAPON_ICON_NON_CHARSET = false
    
    # Set this to true to disable auto Move Posing. When set this to false,
    # You can let the actor to change to any pose while moving.
    DISABLE_AUTO_MOVE_POSE = true
    
    # Set this to true to enable shadow beneath battler.
    BATTLER_SHADOW = true
    
    # Enemies default attack animation ID.
    # First Attack Animation and Second Attack Animation can be defined by
    # notetags <atk ani 1: x> and <atk ani 2: x> respectively.
    ENEMY_ATTACK_ANIMATION = 1
    
  end # Visual
  module Fixes
    # Set this to false to disable auto turn-off the immortal flag. Many people
    # forgot to turn-off immortal flag in an actions sequence, so the targets
    # remain alive even their HP reach zero.
    # Auto Turn-off Immortal will be push to Finish Actions.
    AUTO_IMMORTAL_OFF = true
    
  end # Fixes
end # SYMPHONY