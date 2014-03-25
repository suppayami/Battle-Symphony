#==============================================================================
# ■ Direction
#==============================================================================

module Direction
  
  #--------------------------------------------------------------------------
  # self.pose
  #--------------------------------------------------------------------------
  def self.pose(direction)
    case direction
    when 4; return :left
    when 6; return :right
    when 8; return :up
    when 2; return :down
    when 7; return :left
    when 1; return :left
    when 9; return :right
    when 3; return :right
    end
  end
  
  #--------------------------------------------------------------------------
  # self.non8d_pose
  #--------------------------------------------------------------------------
  def self.non8d_pose(pose)
    case pose
    when :down_l; return :left
    when :down_r; return :right
    when :up_l; return :left
    when :up_r; return :right
    end
  end
  
  #--------------------------------------------------------------------------
  # self.pose
  #--------------------------------------------------------------------------
  def self.direction(pose)
    case pose
    when :left; return 4
    when :right; return 6
    when :up; return 8
    when :down; return 2
    end
  end
  
  #--------------------------------------------------------------------------
  # self.opposite
  #--------------------------------------------------------------------------
  def self.opposite(direction)
    case direction
    when 1; return 9
    when 2; return 8
    when 3; return 7
    when 4; return 6
    when 6; return 4
    when 7; return 3
    when 8; return 2
    when 9; return 1
    else; return direction
    end
  end
  
  #--------------------------------------------------------------------------
  # self.face_coordinate
  #--------------------------------------------------------------------------
  def self.face_coordinate(screen_x, screen_y, destination_x, destination_y)
    x1 = Integer(screen_x)
    x2 = Integer(destination_x)
    y1 = Graphics.height - Integer(screen_y)
    y2 = Graphics.height - Integer(destination_y)
    return if x1 == x2 and y1 == y2
    #---
    angle = Integer(Math.atan2((y2-y1),(x2-x1)) * 1800 / Math::PI)
    if (0..225) === angle or (-225..0) === angle
      direction = 6
    elsif (226..675) === angle
      direction = 9
    elsif (676..1125) === angle
      direction = 8
    elsif (1126..1575) === angle
      direction = 7
    elsif (1576..1800) === angle or (-1800..-1576) === angle
      direction = 4
    elsif (-1575..-1126) === angle
      direction = 1
    elsif (-1125..-676) === angle
      direction = 2
    elsif (-675..-226) === angle
      direction = 3
    end
    return direction
  end
  
end # Direction

#==============================================================================
# ■ Game_ActionResult
#==============================================================================

class Game_ActionResult
  
  #--------------------------------------------------------------------------
  # alias method: clear_hit_flags
  #--------------------------------------------------------------------------
  alias bes_clear_hit_flags clear_hit_flags
  def clear_hit_flags
    return unless @calc
    bes_clear_hit_flags
    @temp_missed = @temp_evaded = @temp_critical = nil
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_bes_flag
  #--------------------------------------------------------------------------
  def clear_bes_flag
    @perfect_hit = false
    @calc = false
    @dmg = false
    @effect = false
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_change_target
  #--------------------------------------------------------------------------
  def clear_change_target
    @check_counter = false
    @check_reflection = false
  end
  
  #--------------------------------------------------------------------------
  # new method: set_perfect
  #--------------------------------------------------------------------------
  def set_perfect
    @perfect_hit = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_calc
  #--------------------------------------------------------------------------
  def set_calc
    @calc = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_dmg
  #--------------------------------------------------------------------------
  def set_dmg
    @dmg = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_effect
  #--------------------------------------------------------------------------
  def set_effect
    @effect = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_counter
  #--------------------------------------------------------------------------
  def set_counter
    @check_counter = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_reflection
  #--------------------------------------------------------------------------
  def set_reflection
    @check_reflection = true
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def evaded=(flag)
    @evaded = @temp_evaded.nil? ? flag : @temp_evaded
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def critical=(flag)
    @critical = @temp_critical.nil? ? flag : @temp_critical
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def misssed=(flag)
    @missed = @temp_missed.nil? ? flag : @temp_missed
  end
  
  #--------------------------------------------------------------------------
  # alias method: hit?
  #--------------------------------------------------------------------------
  alias bes_hit? hit?
  def hit?
    bes_hit? || (@used && @perfect_hit)
  end
  
  #--------------------------------------------------------------------------
  # new method: dmg?
  #--------------------------------------------------------------------------
  def dmg?
    @dmg || !SceneManager.scene_is?(Scene_Battle)
  end
  
  #--------------------------------------------------------------------------
  # new method: effect?
  #--------------------------------------------------------------------------
  def effect?
    @effect || !SceneManager.scene_is?(Scene_Battle)
  end
  
  #--------------------------------------------------------------------------
  # new method: has_damage?
  #--------------------------------------------------------------------------
  def has_damage?
    [@hp_damage, @mp_damage, @tp_damage].any? { |x| x > 0 }
  end
  
  #--------------------------------------------------------------------------
  # new method: check_counter?
  #--------------------------------------------------------------------------
  def check_counter?
    @check_counter
  end
  
  #--------------------------------------------------------------------------
  # new method: check_reflection?
  #--------------------------------------------------------------------------
  def check_reflection?
    @check_reflection
  end
  
end # Game_ActionResult

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method: backup_actions
  #--------------------------------------------------------------------------
  def backup_actions
    @backup_actions = @actions.dup if @actions
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_actions
  #--------------------------------------------------------------------------
  def restore_actions
    @actions = @backup_actions.dup if @backup_actions
    @backup_actions.clear
    @backup_actions = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_cnt
  #--------------------------------------------------------------------------
  alias bes_item_cnt item_cnt
  def item_cnt(user, item)
    return 0 unless @result.check_counter?
    return bes_item_cnt(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_mrf
  #--------------------------------------------------------------------------
  alias bes_item_mrf item_mrf
  def item_mrf(user, item)
    return 0 unless @result.check_reflection?
    return 0 if @magic_reflection
    return bes_item_mrf(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: state_resist_set
  #--------------------------------------------------------------------------
  alias bes_state_resist_set state_resist_set
  def state_resist_set
    result = bes_state_resist_set
    result += [death_state_id] if @immortal
    result
  end
  
  #--------------------------------------------------------------------------
  # alias method: execute_damage
  #--------------------------------------------------------------------------
  alias bes_execute_damage execute_damage
  def execute_damage(user)
    return unless @result.dmg?
    bes_execute_damage(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias bes_make_damage_value make_damage_value
  def make_damage_value(user, item)
    return unless @result.dmg?
    bes_make_damage_value(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_effect_apply
  #--------------------------------------------------------------------------
  alias bes_item_effect_apply item_effect_apply
  def item_effect_apply(user, item, effect)
    return unless @result.effect?
    bes_item_effect_apply(user, item, effect)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_user_effect
  #--------------------------------------------------------------------------
  alias bes_item_user_effect item_user_effect
  def item_user_effect(user, item)
    return unless @result.effect?
    bes_item_user_effect(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: make_miss_popups
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias bes_make_miss_popups make_miss_popups
  def make_miss_popups(user, item)
    @result.restore_damage unless @result.effect?
    bes_make_miss_popups(user, item)
    unless @result.effect?
      @result.store_damage
      @result.clear_damage_values
    end
  end
  end
  
  #--------------------------------------------------------------------------
  # new method: face_coordinate
  #--------------------------------------------------------------------------
  def face_coordinate(destination_x, destination_y)
    direction = Direction.face_coordinate(self.screen_x, self.screen_y, destination_x, destination_y)
    #direction = Direction.opposite(direction) if self.sprite.mirror
    @direction = direction
    return if $imported["BattleSymphony-HB"] && self.use_hb?
    return if SYMPHONY::Visual::DISABLE_AUTO_MOVE_POSE && self.use_custom_charset?
    @pose = Direction.pose(direction)
  end
  
  #--------------------------------------------------------------------------
  # new method: create_movement
  #--------------------------------------------------------------------------
  def create_movement(destination_x, destination_y, frames = 12)
    return if @screen_x == destination_x && @screen_y == destination_y
    @destination_x = destination_x
    @destination_y = destination_y
    frames = [frames, 1].max
    @f = frames.to_f / 2
    @move_x_rate = [(@screen_x - @destination_x).abs / frames, 2].max
    @move_y_rate = [(@screen_y - @destination_y).abs / frames, 2].max
  end
  
  #--------------------------------------------------------------------------
  # new method: create_jump
  #--------------------------------------------------------------------------
  def create_jump(arc)
    @arc = arc
    @parabola[:x] = 0
    @parabola[:y0] = 0
    @parabola[:y1] = @destination_y - @screen_y
    @parabola[:h]  = - (@parabola[:y0] + @arc * 5)
    @parabola[:d]  = (@screen_x - @destination_x).abs
  end
  
  #--------------------------------------------------------------------------
  # new method: create_icon
  #--------------------------------------------------------------------------
  def create_icon(symbol, icon_id = 0)
    delete_icon(symbol)
    #---
    icon = Sprite_Object.new(self.sprite.viewport)
    case symbol
    when :weapon1
      object = self.weapons[0]
      icon_id = object.nil? ? nil : object.icon_index
    when :weapon2
      object = dual_wield? ? self.weapons[1] : nil
      icon_id = object.nil? ? nil : object.icon_index
    when :shield
      object = dual_wield? ? nil : self.equips[1]
      icon_id = object.nil? ? nil : object.icon_index
    when :item
      object = self.current_action.item
      icon_id = object.nil? ? nil : object.icon_index
    else; end
    return if icon_id.nil? || icon_id <= 0
    icon.set_icon(icon_id)
    icon.set_battler(self)
    #---
    @icons[symbol] = icon
  end
    
  #--------------------------------------------------------------------------
  # new method: delete_icon
  #--------------------------------------------------------------------------
  def delete_icon(symbol)
    return unless @icons[symbol]
    @icons[symbol].dispose
    @icons.delete(symbol)
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_icons
  #--------------------------------------------------------------------------
  def clear_icons
    @icons.each { |key, value|
      value.dispose
      @icons.delete(key)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    return unless self.is_moving?
    @move_x_rate = 0 if @screen_x == @destination_x || @move_x_rate.nil?
    @move_y_rate = 0 if @screen_y == @destination_y || @move_y_rate.nil?
    value = [(@screen_x - @destination_x).abs, @move_x_rate].min
    @screen_x += (@destination_x > @screen_x) ? value : -value
    value = [(@screen_y - @destination_y).abs, @move_y_rate].min
    @screen_y += (@destination_y > @screen_y) ? value : -value
  end
  
  #--------------------------------------------------------------------------
  # new method: update_jump
  #--------------------------------------------------------------------------
  def update_jump
    return unless self.is_moving?
    #---
    value = [(@screen_x - @destination_x).abs, @move_x_rate].min
    @screen_x += (@destination_x > @screen_x) ? value : -value
    @parabola[:x] += value
    @screen_y -= @arc_y
    #---
    if @destination_x == @screen_x
      @screen_y = @destination_y
      @arc_y = 0
      @arc = 0
    else
      a = (2.0*(@parabola[:y0]+@parabola[:y1])-4*@parabola[:h])/(@parabola[:d]**2)
      b = (@parabola[:y1]-@parabola[:y0]-a*(@parabola[:d]**2))/@parabola[:d]
      @arc_y = a * @parabola[:x] * @parabola[:x] + b * @parabola[:x] + @parabola[:y0]
    end
    #---
    @screen_y += @arc_y
    @move_x_rate = 0 if @screen_x == @destination_x
    @move_y_rate = 0 if @screen_y == @destination_y
  end
  
  #--------------------------------------------------------------------------
  # new method: update_icons
  #--------------------------------------------------------------------------
  def update_icons
    @icons ||= {}
    @icons.each_value { |value| value.update }
  end
  
  #--------------------------------------------------------------------------
  # new method: update_visual
  #--------------------------------------------------------------------------
  def update_visual
    return unless SceneManager.scene_is?(Scene_Battle)
    return unless SceneManager.scene.spriteset
    correct_origin_position
    #---
    @arc == 0 ? update_movement : update_jump
    update_icons
  end
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    [@move_x_rate, @move_y_rate].any? { |x| x != 0 }
  end
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def dual_attack?
    self.actor? && self.current_action.attack? && self.dual_wield? && self.weapons.size > 1
  end
  
end # Game_Battler

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    return unless @battler
    @battler.is_moving?
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    self.battler_sprites.any? { |sprite| sprite.is_moving? }
  end
  
end # Spriteset_Battle

#==============================================================================
# ■ Window_BattleLog
#==============================================================================

class Window_BattleLog < Window_Selectable
  
  
  
end # Window_BattleLog

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: use_item
  #--------------------------------------------------------------------------
  def use_item
    @scene_item = item = @subject.current_action.item
    targets = @subject.current_action.make_targets.compact
    #---
    attack = @subject.current_action.attack?
    weapon = @subject.weapons[0]
    w_action = attack && weapon
    #---
    targets = targets * 2 if attack && @subject.dual_attack?
    #--- Setup Actions ---
    actions_list = item.setup_actions_list
    actions_list = weapon.setup_actions_list if w_action && weapon.valid_actions?(:setup)
    perform_actions_list(actions_list, targets)
    #--- Item Costs ---
    @subject.use_item(item)
    refresh_status
    #--- YEA - Cast Animation
    process_casting_animation if $imported["YEA-CastAnimations"]
    #--- YEA - Lunatic Object
    if $imported["YEA-LunaticObjects"]
      lunatic_object_effect(:before, item, @subject, @subject)
    end
    #--- Whole Actions ---
    actions_list = item.whole_actions_list
    actions_list = weapon.whole_actions_list if w_action && weapon.valid_actions?(:whole)
    perform_actions_list(actions_list, targets)
    #--- Target Actions ---
    actions_list = item.target_actions_list
    actions_list = weapon.target_actions_list if w_action && weapon.valid_actions?(:target)
    targets.each { |target| 
      next if target.dead?
      perform_actions_list(actions_list, [target])
    }
    #--- Follow Actions ---
    actions_list = item.follow_actions_list
    actions_list = weapon.follow_actions_list if w_action && weapon.valid_actions?(:follow)
    perform_actions_list(actions_list, targets)
    #--- Finish Actions ---
    actions_list = item.finish_actions_list
    actions_list = weapon.finish_actions_list if w_action && weapon.valid_actions?(:finish)
    immortal_flag = ["IMMORTAL", ["TARGETS", "FALSE"]]
    if !actions_list.include?(immortal_flag)
      if SYMPHONY::Fixes::AUTO_IMMORTAL_OFF
        actions_list = [immortal_flag] + actions_list
      end
    end
    perform_actions_list(actions_list, targets)
    #--- YEA - Lunatic Object
    if $imported["YEA-LunaticObjects"]
      lunatic_object_effect(:after, item, @subject, @subject)
    end
    targets.each { |target| 
      next unless target.actor?
      @status_window.draw_item(target.index)
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: invoke_item
  #--------------------------------------------------------------------------
  alias bes_invoke_item invoke_item
  def invoke_item(target, item)
    if $imported["YEA-TargetManager"]
      target = alive_random_target(target, item) if item.for_random?
    end
    bes_invoke_item(target, item)
    #--- Critical Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::CRITICAL_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.critical
    #--- Miss Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::MISS_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.missed
    #--- Evade Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::EVADE_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.evaded
    #--- Fail Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::FAIL_ACTIONS
    perform_actions_list(actions_list, [target]) if !target.result.success
    #--- Damaged Actions
    actions_list = SYMPHONY::DEFAULT_ACTIONS::DAMAGED_ACTION
    perform_actions_list(actions_list, [target]) if target.result.has_damage?
  end
  
  #--------------------------------------------------------------------------
  # alias method: execute_action
  #--------------------------------------------------------------------------
  alias bes_execute_action execute_action
  def execute_action
    bes_execute_action
    #--- Reset Flags ---
    ($game_party.battle_members + $game_troop.members).each { |battler|
      battler.result.set_calc; battler.result.clear
      battler.clear_icons
      battler.set_default_position
      battler.break_pose
    }
    $game_troop.screen.clear_bes_ve if $imported["BattleSymphony-VisualEffect"]
    @status_window.draw_item(@status_window.index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: invoke_counter_attack
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    @log_window.display_counter(target, item)
    last_subject = @subject
    @counter_subject = target
    @subject = target
    #---
    @subject.backup_actions
    #---
    @subject.make_actions
    @subject.current_action.set_attack
    #---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::COUNTER_ACTION
    perform_actions_list(actions_list, [last_subject])
    #---
    @subject.clear_actions
    @subject = last_subject
    #---
    @counter_subject.restore_actions
    #---
    @counter_subject = nil
    @log_window.display_action_results(@subject, item)
    refresh_status
    perform_collapse_check(@subject)
    perform_collapse_check(target)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    @subject.magic_reflection = true
    @log_window.display_reflection(target, item)
    last_subject = @subject
    @reflect_subject = target
    @subject = target
    #---
    @subject.backup_actions
    #---
    @subject.make_actions
    if item.is_a?(RPG::Skill); @subject.current_action.set_skill(item.id)
      else; @subject.current_action.set_item(item.id); end
    #---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::REFLECT_ACTION
    perform_actions_list(actions_list, [last_subject])
    #---
    @subject.clear_actions
    @subject = last_subject
    #---
    @reflect_subject.restore_actions
    #---
    @reflect_subject = nil
    @log_window.display_action_results(@subject, item)
    refresh_status
    perform_collapse_check(@subject)
    perform_collapse_check(target)
    @subject.magic_reflection = false
  end
  
  #--------------------------------------------------------------------------
  # alias method: apply_substitute
  #--------------------------------------------------------------------------
  alias bes_apply_substitute apply_substitute
  def apply_substitute(target, item)
    substitute = bes_apply_substitute(target, item)
    if target != substitute
      @substitute_subject = substitute
    end
    return substitute
  end
    
  #--------------------------------------------------------------------------
  # new method: wait_for_move
  #--------------------------------------------------------------------------
  def wait_for_move
    update_for_wait
    update_for_wait while @spriteset.is_moving?
  end
  
  #--------------------------------------------------------------------------
  # new method: spriteset
  #--------------------------------------------------------------------------
  def spriteset
    @spriteset
  end
  
  #--------------------------------------------------------------------------
  # compatible overwrite method: separate_ani?
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  def separate_ani?(target, item)
    return false
  end
  end

  #--------------------------------------------------------------------------
  # new method: perform_collapse_check
  #--------------------------------------------------------------------------
  def perform_collapse_check(target)
    target.perform_collapse_effect if target.can_collapse?
    @log_window.wait_for_effect
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_log_window
  #--------------------------------------------------------------------------
#~   def create_log_window
#~     @log_window = Window_BattleLog.new
#~   end
  
end # Scene_Battle