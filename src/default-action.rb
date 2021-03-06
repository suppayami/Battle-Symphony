module SYMPHONY
  module DEFAULT_ACTIONS
      
    #==========================================================================
    # Default Magic Actions
    # -------------------------------------------------------------------------
    # These are the default magic actions for all Magic Skills as well as Certain
    # hit Skills. Battlers will play these actions when use a Magic/Certain Hit
    # Skill unless You customize it with Symphony Tags.
    #==========================================================================
    MAGIC_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
      ["POSE", ["USER", "CAST"]],
      ["STANCE", ["USER", "CAST"]],
    ] # Do not remove this.
    MAGIC_WHOLE =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["AUTO SYMPHONY", ["SKILL FULL"]],
    ] # Do not remove this.
    MAGIC_TARGET =[
    ] # Do not remove this.
    MAGIC_FOLLOW =[
      ["WAIT FOR MOVE"],
    ] # Do not remove this.
    MAGIC_FINISH =[
      ["IMMORTAL", ["TARGETS", "FALSE"]],
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Default Physical Actions
    # -------------------------------------------------------------------------
    # These are the default physical actions for all Physical Skills as well as
    # Normal Attack. Battlers will play these actions when use a Physical
    # Skill unless You customize it with Symphony Tags.
    #==========================================================================
    PHYSICAL_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
    ] # Do not remove this.
    PHYSICAL_WHOLE =[
    ] # Do not remove this.
    PHYSICAL_TARGET =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["POSE", ["USER", "FORWARD"]],
      ["STANCE", ["USER", "FORWARD"]],
      ["MOVE USER", ["TARGET", "BODY", "WAIT"]],
      ["AUTO SYMPHONY", ["SINGLE SWING"]],
      ["AUTO SYMPHONY", ["SKILL FULL", "unless attack"]],
      ["AUTO SYMPHONY", ["ATTACK FULL", "if attack"]],
    ] # Do not remove this.
    PHYSICAL_FOLLOW =[
      ["WAIT FOR MOVE"],
    ] # Do not remove this.
    PHYSICAL_FINISH =[
      ["IMMORTAL", ["TARGETS", "FALSE"]],
      ["ICON DELETE", ["USER", "WEAPON"]],
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Default Item Actions
    # -------------------------------------------------------------------------
    # These are the default item actions for all Items. Battlers will play these
    # actions when use an Item unless You customize it with Symphony Tags.
    #==========================================================================
    ITEM_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
      ["AUTO SYMPHONY", ["ITEM FLOAT"]],
    ] # Do not remove this.
    ITEM_WHOLE =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["AUTO SYMPHONY", ["ITEM FULL"]],
    ] # Do not remove this.
    ITEM_TARGET =[
    ] # Do not remove this.
    ITEM_FOLLOW =[
      ["WAIT FOR MOVE"],
      ["IMMORTAL", ["TARGETS", "FALSE"]],
    ] # Do not remove this.
    ITEM_FINISH =[
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Critical Action
    # -------------------------------------------------------------------------
    # This is the critical action. This action will be played when a battler 
    # scores a critical hit.
    #==========================================================================
    CRITICAL_ACTIONS =[
      ["SCREEN", ["FLASH", "30", "255", "255", "255"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Miss Action
    # -------------------------------------------------------------------------
    # This is the miss action. This action will be played when a battler attacks
    # miss.
    #==========================================================================
    MISS_ACTIONS =[
      ["POSE", ["TARGET", "EVADE"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Evade Action
    # -------------------------------------------------------------------------
    # This is the evade action. This action will be played when a battler evades.
    #==========================================================================
    EVADE_ACTIONS =[
      ["POSE", ["TARGET", "EVADE"]],
    ] # Do not remove this.

    #==========================================================================
    # Fail Action
    # -------------------------------------------------------------------------
    # This is the fail action. This action will be played when a battler fails
    # on casting skill.
    #==========================================================================
    FAIL_ACTIONS =[
    
    ] # Do not remove this.
      
    #==========================================================================
    # Damaged Action
    # -------------------------------------------------------------------------
    # This is the damaged action. This action will be played when a battler is
    # damaged.
    #==========================================================================
    DAMAGED_ACTION = [
      ["POSE", ["TARGET", "DAMAGE"]],
      ["STANCE", ["TARGET", "STRUCK"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Counter Action
    # -------------------------------------------------------------------------
    # This is the counter action. This action will be played when a battler
    # counters an attack.
    #==========================================================================
    COUNTER_ACTION = [
      ["MOVE COUNTER SUBJECT", ["FORWARD", "WAIT"]],
      ["AUTO SYMPHONY", ["SINGLE SWING COUNTER"]],
      ["AUTO SYMPHONY", ["SKILL FULL COUNTER"]],
      ["ICON DELETE", ["COUNTER SUBJECT", "WEAPON"]],
      ["POSE", ["COUNTER SUBJECT", "BREAK"]],
      ["STANCE", ["COUNTER SUBJECT", "BREAK"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Reflect Action
    # -------------------------------------------------------------------------
    # This is the reflect action. This action will be played when a battler
    # reflects a magic.
    #==========================================================================
    REFLECT_ACTION = [
      ["MOVE REFLECT SUBJECT", ["FORWARD", "WAIT"]],
      ["POSE", ["REFLECT SUBJECT", "CAST"]],
      ["STANCE", ["REFLECT SUBJECT", "CAST"]],
      ["AUTO SYMPHONY", ["SKILL FULL COUNTER"]],
      ["POSE", ["REFLECT SUBJECT", "BREAK"]],
      ["STANCE", ["REFLECT SUBJECT", "BREAK"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Substitute Action
    # -------------------------------------------------------------------------
    # This is the reflect action. This action will be played when a battler
    # reflects a magic.
    #==========================================================================
    SUBSTITUTE_ACTION = [
      ["TELEPORT SUBSTITUTE SUBJECT", ["TARGET", "BODY", "WAIT"]],
    ] # Do not remove this.
    
    SUBSTITUTE_END_ACTION = [
      ["TELEPORT SUBSTITUTE SUBJECT", ["ORIGIN", "WAIT"]],
    ] # Do not remove this.
    
  end # DEFAULT_ACTIONS
end # SYMPHONY