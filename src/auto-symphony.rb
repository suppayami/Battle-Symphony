module SYMPHONY
  AUTO_SYMPHONY = { # Start
    # "Key" => [Symphony Sequence],
    
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: return origin
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This AutoSymphony returns the active battler and all of its targets back
    # to their original locations. Used often at the end of a skill, item,
    # or any other action sequence.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "RETURN ORIGIN" => [
      ["STANCE", ["USER", "ORIGIN"]],
      ["MOVE USER", ["ORIGIN", "WAIT"]],
      ["POSE", ["USER", "BREAK"]],
      ["MOVE EVERYTHING", ["ORIGIN"]],
    ], # end RETURN ORIGIN
     
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: single swing
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the active battler to perform a single-handed weapon swing
    # downwards.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SINGLE SWING" => [
      ["ICON CREATE", ["USER", "WEAPON"]],
      ["ICON", ["USER", "WEAPON", "SWING"]],
      ["POSE", ["USER", "2H SWING"]],
      ["STANCE", ["USER", "ATTACK"]],
    ], # end SINGLE SWING
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: single swing counter
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the countering battler to perform a single-handed weapon 
    # swing downwards.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SINGLE SWING COUNTER" => [
      ["ICON CREATE", ["COUNTER SUBJECT", "WEAPON"]],
      ["ICON", ["COUNTER SUBJECT", "WEAPON", "SWING"]],
      ["POSE", ["COUNTER SUBJECT", "2H SWING"]],
      ["STANCE", ["USER", "ATTACK"]],
    ], # end SINGLE SWING COUNTER
             
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: item float
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the active battler to enter a "Cast" stance to make the
    # active battler appear to throw the item upward. The icon of the item
    # is then created and floats upward.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ITEM FLOAT" => [
      ["POSE", ["USER", "CAST"]],
      ["STANCE", ["USER", "ITEM"]],
      ["ICON CREATE", ["USER", "ITEM"]],
      ["ICON", ["USER", "ITEM", "FLOAT", "WAIT"]],
    ], # end ITEM FLOAT
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: attack full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This triggers the full course for an attack effect. Attack's animation
    # plays and waits until it ends. The damage, status changes, and anything
    # else the attack may do to the target. Once the attack effect is over,
    # the target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ATTACK FULL" => [
      ["ATTACK EFFECT", ["COUNTER CHECK"]],
      ["ATTACK ANIMATION", ["WAIT"]],
      ["ATTACK EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD"]],
    ], # end ATTACK FULL
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: skill full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This trigger the full course for a skill's effect. The skill animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the skill may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SKILL FULL" => [
      ["SKILL EFFECT", ["COUNTER CHECK"]],
      ["SKILL EFFECT", ["REFLECT CHECK"]],
      ["SKILL ANIMATION", ["WAIT"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless skill.for_friend?"]],
    ], # end SKILL FULL
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: skill full counter
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This trigger the full course for a skill's effect. The skill animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the skill may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # This trigger is used in countering/reflecting skill.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SKILL FULL COUNTER" => [
      ["ATTACK ANIMATION", ["TARGETS", "WAIT", "if attack"]],
      ["SKILL ANIMATION", ["TARGETS", "WAIT", "unless attack"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless skill.for_friend?"]],
    ], # end SKILL FULL COUNTER
    
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: item full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This triggers the full course for an item's effect. The item animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the item may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ITEM FULL" => [
      ["SKILL EFFECT", ["COUNTER CHECK"]],
      ["SKILL EFFECT", ["REFLECT CHECK", "unless skill.for_all?"]],
      ["SKILL ANIMATION", ["WAIT"]],
      ["ICON", ["USER", "ITEM", "FADE OUT", "WAIT"]],
      ["ICON DELETE", ["USER", "ITEM"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless item.for_friend?"]],
    ], # end ITEM FULL
    
  } # Do not remove this.
end # SYMPHONY