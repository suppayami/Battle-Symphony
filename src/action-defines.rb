#==============================================================================
# ■ Scene_Battle - Defines Tags Names
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: perform_actions_list
  #--------------------------------------------------------------------------
  def perform_actions_list(actions, targets)
    #--- Create Formers ---
    former_action = @action
    former_values = (@action_values != nil) ? @action_values.clone : nil
    former_targets = (@action_targets != nil) ? @action_targets.clone : nil
    former_item = (@scene_item != nil) ? @scene_item.clone : nil
    #--- Create Current ---
    @action_targets = targets
    actions.each { |action|
      @action = action[0].upcase; @action_values = action[1]
      @action_values.each { |s| s.upcase! if s.is_a?(String) } if @action_values
      break unless SceneManager.scene_is?(Scene_Battle)
      break if @subject && @subject.dead?
      next unless action_condition_met
      case @action.upcase
      
        when /ANIMATION[ ](\d+)|SKILL ANIMATION|ATTACK ANIMATION|ANIMATION/i
          action_animation
      
        when /ATTACK EFFECT|SKILL EFFECT/i
          action_skill_effect
          
        when /AUTO SYMPHONY|AUTOSYMPHONY/i
          action_autosymphony
          
        when /ICON CREATE|CREATE ICON/i
          action_create_icon
          
        when /ICON DELETE|DELETE ICON/i
          action_delete_icon
          
        when "ICON", "ICON EFFECT"
          action_icon_effect
          
        when /ICON THROW[ ](.*)/i
          action_icon_throw
          
        when /IF[ ](.+)/i
          action_condition
          
        when /JUMP[ ](.*)/i
          action_move
                    
        when /MESSAGE/i
          action_message
          
        when /MOVE[ ](.*)/i
          action_move
          
        when /IMMORTAL/i
          action_immortal
          
        when /POSE/i
          action_pose
          
        when /STANCE/i
          action_stance
          
        when /UNLESS[ ](.+)/i
          action_condition
          
        when /TELEPORT[ ](.*)/i
          action_move
          
        when "WAIT", "WAIT SKIP", "WAIT FOR ANIMATION", "WAIT FOR MOVE",
          "WAIT FOR MOVEMENT", "ANI WAIT"
          action_wait
          
        else
          imported_symphony
      end
    }
    #--- Release Formers ---
    @action = former_action
    @action_values = former_values
    @action_targets = former_targets
    @scene_item = former_item
  end
  
end # Scene_Battle
#==============================================================================
# ■ Scene_Battle - Defines Tags Actions
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_condition_met
  #--------------------------------------------------------------------------
  def action_condition_met
    target = @action_targets[0]
    targets = @action_targets
    user = @subject
    skill = item = @scene_item
    attack = false
    if @counter_subject || (user.current_action && user.current_action.attack?)
      attack = true
    end
    weapons = user.weapons if user.actor?
    @action_condition ||= []
    @action_condition.pop if @action.upcase == "END"
    if @action_condition.size > 0
      @action_condition.each { |action_condition|
        action_condition =~ /(IF|UNLESS)[ ](.+)/i
        condition_type = $1.upcase
        condition_value = $2.downcase
        #---
        if condition_type == "IF"
          return false unless eval(condition_value)
        elsif condition_type == "UNLESS"
          return false if eval(condition_value)
        end
      }
    end
    if @action_values
      @action_values.each { |value|
        case value
        when /IF[ ](.*)/i
          eval("return false unless " + $1.to_s.downcase)
        when /UNLESS[ ](.*)/i
          eval("return false if " + $1.to_s.downcase)
        end
      }
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: get_action_mains
  #--------------------------------------------------------------------------
  def get_action_mains
    result = []
    case @action.upcase
    when /(?:USER)/i
      result.push(@subject) if @subject
    when /(?:TARGET|TARGETS)/i
      result = @action_targets
    when /(?:COUNTER SUBJECT)/i
      result = [@counter_subject]
    when /(?:REFLECT SUBJECT)/i
      result = [@reflect_subject]
    when /(?:SUBSTITUTE SUBJECT)/i
      result = [@substitute_subject]
    when /(?:ACTORS|PARTY|ACTORS LIVING)/i
      result = $game_party.alive_members
    when /(?:ALL ACTORS|ACTORS ALL)/i
      result = $game_party.battle_members
    when /(?:ACTORS NOT USER|PARTY NOT USER)/i
      result = $game_party.alive_members
      result.delete(@subject) if @subject
    when /(?:ENEMIES|TROOP|ENEMIES LIVING)/i
      result = $game_troop.alive_members
    when /(?:ALL ENEMIES|ENEMIES ALL)/i
      result = $game_troop.battle_members
    when /(?:ENEMIES NOT USER|ENEMIES NOT USER)/i
      result = $game_troop.alive_members
      result.delete(@subject) if @subject
    when /ACTOR[ ](\d+)/i
      result.push($game_party.battle_members[$1.to_i])
    when /ENEMY[ ](\d+)/i
      result.push($game_troop.battle_members[$1.to_i])
    when /(?:EVERYTHING|EVERYBODY)/i
      result = $game_party.alive_members + $game_troop.alive_members
    when /(?:EVERYTHING NOT USER|EVERYBODY NOT USER)/i
      result = $game_party.alive_members + $game_troop.alive_members
      result.delete(@subject) if @subject
    when /(?:ALLIES|FRIENDS)/i
      result = @subject.friends_unit.alive_members if @subject
    when /(?:OPPONENTS|RIVALS)/i
      result = @subject.opponents_unit.alive_members if @subject
    when /(?:FRIENDS NOT USER)/i
      if @subject
        result = @subject.friends_unit.alive_members 
        result.delete(@subject)
      end
    when /(?:FOCUS)/i
      result = @action_targets
      result.push(@subject) if @subject
    when /(?:NOT FOCUS|NON FOCUS)/i
      result = $game_party.alive_members + $game_troop.alive_members
      result -= @action_targets
      result.delete(@subject) if @subject
    else;
    end
    return result.compact
  end
  
  #--------------------------------------------------------------------------
  # new method: get_action_targets
  #--------------------------------------------------------------------------
  def get_action_targets
    result = []
    @action_values.reverse.each { |value|
      next if value.nil?
      case value.upcase
      when /(?:USER)/i
        result.push(@subject) if @subject
      when /(?:TARGET|TARGETS)/i
        result = @action_targets
      when /(?:COUNTER SUBJECT)/i
        result = [@counter_subject]
      when /(?:REFLECT SUBJECT)/i
        result = [@reflect_subject]
      when /(?:SUBSTITUTE SUBJECT)/i
        result = [@substitute_subject]
      when /(?:ACTORS|PARTY|ACTORS LIVING)/i
        result = $game_party.alive_members
      when /(?:ALL ACTORS|ACTORS ALL)/i
        result = $game_party.battle_members
      when /(?:ACTORS NOT USER|PARTY NOT USER)/i
        result = $game_party.alive_members
        result.delete(@subject) if @subject
      when /(?:ENEMIES|TROOP|ENEMIES LIVING)/i
        result = $game_troop.alive_members
      when /(?:ALL ENEMIES|ENEMIES ALL)/i
        result = $game_troop.battle_members
      when /(?:ENEMIES NOT USER|ENEMIES NOT USER)/i
        result = $game_troop.alive_members
        result.delete(@subject) if @subject
      when /ACTOR[ ](\d+)/i
        result.push($game_party.battle_members[$1.to_i])
      when /ENEMY[ ](\d+)/i
        result.push($game_troop.battle_members[$1.to_i])
      when /(?:EVERYTHING|EVERYBODY)/i
        result = $game_party.alive_members + $game_troop.alive_members
      when /(?:EVERYTHING NOT USER|EVERYBODY NOT USER)/i
        result = $game_party.alive_members + $game_troop.alive_members
        result.delete(@subject) if @subject
      when /(?:ALLIES|FRIENDS)/i
        result = @subject.friends_unit.alive_members if @subject
      when /(?:OPPONENTS|RIVALS)/i
        result = @subject.opponents_unit.alive_members if @subject
      when /(?:FRIENDS NOT USER)/i
        if @subject
          result = @subject.friends_unit.alive_members 
          result.delete(@subject)
        end
      when /(?:NOT FOCUS|NON FOCUS)/i
        result = $game_party.alive_members + $game_troop.alive_members
        result -= @action_targets
        result.delete(@subject)
      when /(?:FOCUS)/i
        result = @action_targets
        result.push(@subject) if @subject
      else;
      end
    }
    return result.compact
  end
  
  #--------------------------------------------------------------------------
  # new method: action_animation
  #--------------------------------------------------------------------------
  def action_animation
    targets = get_action_targets
    targets = @action_targets if ["SKILL ANIMATION", "ATTACK ANIMATION"].include?(@action.upcase)
    return if targets.size == 0
    #---
    case @action.upcase
    when /ANIMATION[ ](\d+)/i
      animation_id = [$1.to_i]
    when "SKILL ANIMATION", "ANIMATION"
      return unless @subject.current_action.item
      animation_id = [@subject.current_action.item.animation_id]
    when "ATTACK ANIMATION"
      animation_id = [@subject.atk_animation_id1]
      animation_id = [@subject.atk_animation_id2] if @subject.atk_animation_id2 > 0 && @action_values[1].to_i == 2
    when "LAST ANIMATION"
      animation_id = [@last_animation_id]
    end
    mirror = true if @action_values.include?("MIRROR")
    #---
    animation_id = [@subject.atk_animation_id1] if animation_id == [-1]
    #---
    ani_count = 0
    animation_id.each { |id|
      wait_for_animation if ani_count > 0
      mirror = !mirror if ani_count > 0 
      animation = $data_animations[id]
      #---
      return unless animation
      if animation.to_screen?; targets[0].animation_id = id; end
      if !animation.to_screen?
        targets.each {|target| target.animation_id = id}
      end
      targets.each {|target| target.animation_mirror = mirror}
      ani_count += 1
    }
    @last_animation_id = animation_id[0]
    return unless @action_values.include?("WAIT")
    wait_for_animation
  end
  
  #--------------------------------------------------------------------------
  # new method: action_skill_effect
  #--------------------------------------------------------------------------
  def action_skill_effect
    return unless @subject
    return unless @subject.alive?
    return unless @subject.current_action.item
    targets = @action_targets.uniq
    #--- substitute ---
    substitutes = []
    targets.each { |target|
      substitutes.push(target.friends_unit.substitute_battler)
    }
    substitutes = substitutes.uniq
    #---
    item = @subject.current_action.item
    #---
    if @action_values.include?("CLEAR")
      targets.each { |target| target.result.set_calc; target.result.clear }
      return
    end
    #---
    if @action_values.include?("COUNTER CHECK")
      targets.each { |target| target.result.set_counter }
      return
    elsif @action_values.include?("REFLECT CHECK")
      targets.each { |target| target.result.set_reflection }
      return
    end
    #---
    array = []
    array.push("calc") if @action_values.include?("CALC")
    array = ["perfect"] if @action_values.include?("PERFECT")
    @action_values.each {|value| array.push(value.downcase) unless ["PERFECT", "CALC"].include?(value)}
    array = ["calc", "dmg", "effect"] if @action_values.include?("WHOLE") || @action_values.size == 0
    #--- substitute flag ---
    if substitutes
      substitutes.each { |substitute|
        next unless substitute
        substitute.result.clear_bes_flag
        array.each {|value| str = "substitute.result.set_#{value}"; eval(str)}
      }
    end
    #---
    targets.each { |target| 
      target.result.clear_bes_flag
      array.each {|value| str = "target.result.set_#{value}"; eval(str)}
      item.repeats.times { invoke_item(target, item) } 
      target.result.clear_change_target
      @substitute_subject.result.clear_change_target if @substitute_subject
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_autosymphony
  #--------------------------------------------------------------------------
  def action_autosymphony
    key = @action_values[0].to_s.upcase
    return unless SYMPHONY::AUTO_SYMPHONY.include?(key)
    actions_list = SYMPHONY::AUTO_SYMPHONY[key]
    perform_actions_list(actions_list, @action_targets)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_create_icon
  #--------------------------------------------------------------------------
  def action_create_icon
    targets = get_action_targets
    return if targets.size == 0
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
      attachment = :hand1
    when "WEAPON2"
      symbol = :weapon2
      attachment = :hand2
    when "SHIELD"
      symbol = :shield
      attachment = :shield
    when "ITEM"
      symbol = :item
      attachment = :middle
    else
      symbol = @action_values[1]
      attachment = :middle
    end
    #---
    case @action_values[2]
    when "HAND", "HAND1"
      attachment = :hand1
    when "HAND2", "SHIELD"
      attachment = :hand2
    when "ITEM"
      attachment = :item
    when "MIDDLE", "BODY"
      attachment = :middle
    when "TOP", "HEAD"
      attachment = :top
    when "BOTTOM", "FEET", "BASE"
      attachment = :base
    end
    #---
    targets.each { |target|
      next if target.sprite.nil?
      next if !target.use_charset? && !SYMPHONY::Visual::WEAPON_ICON_NON_CHARSET && [:weapon1, :weapon2].include?(symbol)
      target.create_icon(symbol, @action_values[3].to_i)
      next if target.icons[symbol].nil?
      target.icons[symbol].set_origin(attachment)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_delete_icon
  #--------------------------------------------------------------------------
  def action_delete_icon
    targets = get_action_targets
    return if targets.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    targets.each { |target| target.delete_icon(symbol) }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_icon_effect
  #--------------------------------------------------------------------------
  def action_icon_effect
    targets = get_action_targets
    return if targets.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    targets.each { |target|
      icon = target.icons[symbol]
      next if icon.nil?
      total_frames = 8
      case @action_values[2]
      when "ANGLE"
        angle = @action_values[3].to_i
        icon.set_angle(angle)
      when "ROTATE", "REROTATE"
        angle = @action_values[3].to_i
        angle = -angle if @action_values[2] == "REROTATE"
        total_frames = @action_values[4].to_i
        total_frames = 8 if total_frames == 0
        icon.create_angle(angle, total_frames)
      when /ANIMATION[ ](\d+)/i
        animation = $1.to_i
        if $data_animations[animation].nil?; return; end
        total_frames = $data_animations[animation].frame_max
        total_frames *= 4 unless $imported["YEA-CoreEngine"]
        total_frames *= YEA::CORE::ANIMATION_RATE if $imported["YEA-CoreEngine"]
        icon.start_animation($data_animations[animation])
      when /MOVE_X[ ](\d+)/i
        move_x = $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(move_x, icon.y, total_frames)
      when /MOVE_Y[ ](\d+)/i
        move_y = $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(icon.x, move_y, total_frames)
      when /CUR_X[ ]([\-]?\d+)/i
        move_x = icon.x + $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(move_x, icon.y, total_frames)
      when /CUR_Y[ ]([\-]?\d+)/i
        move_y = icon.y + $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(icon.x, move_y, total_frames)
      when "FADE IN"
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        rate = Integer(256.0/total_frames)
        icon.set_fade(rate)
      when "FADE OUT"
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        rate = Integer(256.0/total_frames)
        icon.set_fade(-rate)
      when "FLOAT"
        total_frames = @action_values[3].to_i
        total_frames = 24 if total_frames == 0
        icon.create_move_direction(8, total_frames, total_frames)
      when "SWING"
        total_frames = 10
        icon.set_angle(0)
        icon.create_angle(90, total_frames)
      when "UPSWING"
        total_frames = 10
        icon.set_angle(90)
        icon.create_angle(0, total_frames)
      when "STAB", "THRUST"
        total_frames = 8
        direction = Direction.direction(target.pose)
        direction = Direction.opposite(direction) if target.sprite.mirror
        case direction
        when 8
          icon_direction = 8
          icon.set_angle(-45)
        when 4
          icon_direction = 4
          icon.set_angle(45)
        when 6
          icon_direction = 6
          icon.set_angle(-135)
        when 2
          icon_direction = 2
          icon.set_angle(135)
        end
        icon.create_move_direction(Direction.opposite(icon_direction), 40, 1)
        icon.update
        icon.create_move_direction(icon_direction, 32, total_frames)
      when "CLAW"
        total_frames = 8
        direction = Direction.direction(target.pose)
        direction = Direction.opposite(direction) if target.sprite.mirror
        case direction
        when 8
          icon_direction = 7
          back_direction = 3
        when 4
          icon_direction = 1
          back_direction = 9
        when 6
          icon_direction = 3
          back_direction = 7
        when 2
          icon_direction = 9
          back_direction = 1
        end
        icon.create_move_direction(back_direction, 32, 1)
        icon.update
        icon.create_move_direction(icon_direction, 52, total_frames)
      end
      #--- 
      if @action_values.include?("WAIT")
        update_basic while icon.effecting?
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_icon_throw
  #--------------------------------------------------------------------------
  def action_icon_throw
    mains = get_action_mains
    targets = get_action_targets
    return if mains.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    mains.each { |main|
      icon = main.icons[symbol]
      next if icon.nil?
      total_frames = @action_values[3].to_i
      total_frames = 12 if total_frames <= 0
      arc = @action_values[2].to_f
      #---
      targets.each { |target|
        move_x = target.screen_x
        move_y = target.screen_y - target.sprite.height / 2
        icon.create_movement(move_x, move_y, total_frames)
        icon.create_arc(arc)
        if @action_values.include?("WAIT")
          update_basic while icon.effecting?
        end
      }
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_condition
  #--------------------------------------------------------------------------
  def action_condition
    @action_condition ||= []
    @action_condition.push(@action.dup)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_message
  #--------------------------------------------------------------------------
  def action_message
    user = @subject
    return unless user
    item = @subject.current_action.item
    return unless item
    @log_window.display_use_item(@subject, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_move
  #--------------------------------------------------------------------------
  def action_move
    movers = get_action_mains
    return unless movers.size > 0
    return if SYMPHONY::View::EMPTY_VIEW
    #--- Get Location ---
    case @action_values[0]
    #---
    when "FORWARD", "BACKWARD"
      distance = @action_values[1].to_i
      distance = @action_values[0] == "FORWARD" ? 16 : 8 if distance <= 0
      frames = @action_values[2].to_i
      frames = 8 if frames <= 0
      movers.each { |mover|
        next unless mover.exist?
        direction = mover.direction
        destination_x = mover.screen_x
        destination_y = mover.screen_y
        case direction
        when 1; move_x = distance / -2; move_y = distance /  2
        when 2; move_x = distance *  0; move_y = distance *  1
        when 3; move_x = distance / -2; move_y = distance /  2
        when 4; move_x = distance * -1; move_y = distance *  0
        when 6; move_x = distance *  1; move_y = distance *  0
        when 7; move_x = distance / -2; move_y = distance / -2
        when 8; move_x = distance *  0; move_y = distance * -1
        when 9; move_x = distance /  2; move_y = distance / -2
        else; return
        end
        destination_x += @action_values[0] == "FORWARD" ? move_x : - move_x
        destination_y += @action_values[0] == "FORWARD" ? move_y : - move_y
        mover.face_coordinate(destination_x, destination_y) unless @action_values[0] == "BACKWARD"
        mover.create_movement(destination_x, destination_y, frames)
        case @action.upcase
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.create_jump(arc)
        end
      }
    #---
    when "ORIGIN", "RETURN"
      frames = @action_values[1].to_i
      frames = 20 if frames <= 0
      movers.each { |mover|
        next unless mover.exist?
        destination_x = mover.origin_x
        destination_y = mover.origin_y
        next if destination_x == mover.screen_x && destination_y == mover.screen_y
        if @action_values[0] == "ORIGIN"
          mover.face_coordinate(destination_x, destination_y)
        end
        mover.create_movement(destination_x, destination_y, frames)
        case @action.upcase
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.create_jump(arc)
        end
      }
    #---
    when "TARGET", "TARGETS", "USER"
      frames = @action_values[2].to_i
      frames = 20 if frames <= 0
      #---
      case @action_values[0]
      when "USER"
        targets = [@subject]
      when "TARGET", "TARGETS"
        targets = @action_targets
      end
      #---
      destination_x = destination_y = 0
      case @action_values[1]
      when "BASE", "FOOT", "FEET"
        targets.each { |target|
          destination_x += target.screen_x; destination_y += target.screen_y
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
          }
        }
      #---
      when "BODY", "MIDDLE", "MID"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height / 2
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      when "CENTER"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height/2
        }
      #---
      when "HEAD", "TOP"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      when "BACK"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      else
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y
        }
      end
      #---
      destination_x /= targets.size
      destination_y /= targets.size
      movers.each { |mover|
        next unless mover.exist?
        next if mover.screen_x == destination_x && mover.screen_y == destination_y
        case @action.upcase
        when /MOVE[ ](.*)/i
          mover.face_coordinate(destination_x, destination_y)
          mover.create_movement(destination_x, destination_y, frames)
        when /TELEPORT[ ](.*)/i 
          mover.screen_x = destination_x
          mover.screen_y = destination_y
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.face_coordinate(destination_x, destination_y)
          mover.create_movement(destination_x, destination_y, frames)
          mover.create_jump(arc)
        end
      }
    #---
    end
    #---
    return unless @action_values.include?("WAIT")
    wait_for_move
  end
  
  #--------------------------------------------------------------------------
  # new method: action_immortal
  #--------------------------------------------------------------------------
  def action_immortal
    targets = get_action_targets
    return unless targets.size > 0
    targets.each { |target|
      next unless target.alive?
      case @action_values[1].upcase
      when "TRUE", "ON", "ENABLE"
        target.immortal = true
      when "OFF", "FALSE", "DISABLE"
        target.immortal = false
        target.refresh
        perform_collapse_check(target)
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_pose
  #--------------------------------------------------------------------------
  def action_pose
    targets = get_action_targets
    return unless targets.size > 0
    #---
    case @action_values[1]
    when "BREAK", "CANCEL", "RESET", "NORMAL"
      targets.each { |target| target.break_pose }
      return
    when "IDLE", "READY"
      pose_key = :ready
    when "DAMAGE", "DMG"
      pose_key = :damage
    when "PIYORI", "CRITICAL", "DAZED", "DAZE", "DIZZY"
      pose_key = :critical
    when "MARCH", "FORWARD"
      pose_key = :marching
    when "VICTORY", "POSE"
      pose_key = :victory
    when "EVADE", "DODGE"
      pose_key = :dodge
    when "DOWN", "DOWNED", "FALLEN"
      pose_key = :fallen
    when "2H", "2H SWING"
      pose_key = :swing2h
    when "1H", "1H SWING"
      pose_key = :swing1h
    when "2H REVERSE", "2H SWING REVERSE"
      pose_key = :r2hswing
      reverse_pose = true
    when "1H REVERSE", "1H SWING REVERSE"
      pose_key = :r1hswing
      reverse_pose = true
    when "CAST", "INVOKE", "ITEM", "MAGIC"
      pose_key = :cast
    when "CHANT", "CHANNEL", "CHARGE"
      pose_key = :channeling
    else; return
    end
    #---
    return unless $imported["BattleSymphony-8D"]
    #---
    targets.each { |target| 
      next unless target.exist?
      next unless target.use_8d?
      target.pose = pose_key
      target.force_pose = true
      target.reverse_pose = reverse_pose
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_stance
  #--------------------------------------------------------------------------
  def action_stance
    targets = get_action_targets
    return unless targets.size > 0
    #---
    case @action_values[1]
    when "BREAK", "CANCEL", "RESET", "NORMAL"
      targets.each { |target| target.break_pose }
      return
    when "IDLE", "READY"
      pose_key = :idle
    when "DAMAGE", "DMG", "STRUCK"
      pose_key = :struck
    when "PIYORI", "CRITICAL", "DAZED", "DAZE", "DIZZY", "WOOZY"
      pose_key = :woozy
    when "VICTORY"
      pose_key = :victory
    when "EVADE", "DODGE", "DEFEND"
      pose_key = :defend
    when "DOWN", "DOWNED", "FALLEN", "DEAD"
      pose_key = :dead
    when "SWING", "ATTACK", "SLASH"
      pose_key = :attack
    when "CAST", "INVOKE", "MAGIC"
      pose_key = :magic
    when "ITEM"
      pose_key = :item
    when "SKILL", "PHYSICAL"
      pose_key = :skill
    when "FORWARD", "MOVE", "TARGET"
      pose_key = :advance
    when "ORIGIN", "BACK", "RETREAT"
      pose_key = :retreat
    else
      pose_key = @action_values[1].downcase.to_sym
    end
    #---
    return if !$imported["BattleSymphony-HB"] && !$imported["BattleSymphony-CBS"]
    #---
    targets.each { |target| 
      next unless target.exist?
      next if !target.use_hb? && !target.use_cbs?
      target.pose = pose_key
      target.force_pose = true
    }
  end
  
  #--------------------------------------------------------------------------
  # action_wait
  #--------------------------------------------------------------------------
  def action_wait
    case @action
    when "WAIT FOR ANIMATION"
      wait_for_animation
      return
    when "WAIT FOR MOVE", "WAIT FOR MOVEMENT"
      wait_for_move
      return
    end
    frames = @action_values[0].to_i
    frames *= $imported["YEA-CoreEngine"] ? YEA::CORE::ANIMATION_RATE : 4 if @action == "ANI WAIT"
    skip = @action_values.include?("SKIP")
    skip = true if @action == "WAIT SKIP"
    skip ? wait(frames) : abs_wait(frames)
  end
  
end # Scene_Battle