#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :origin_x 
  attr_accessor :origin_y
  attr_accessor :screen_x
  attr_accessor :screen_y
  attr_accessor :pose
  attr_accessor :immortal
  attr_accessor :icons
  attr_accessor :direction
  attr_accessor :force_pose
  attr_accessor :reverse_pose
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias bes_initialize initialize
  def initialize
    bes_initialize
    @screen_x = 0
    @screen_y = 0
    #---
    @move_x_rate = 0
    @move_y_rate = 0
    #---
    @immortal = false
    #---
    @icons = {}
    @force_pose = false
    @reverse_pose = false
    #---
    @hp = 1 # Fix Change Party in Battle.
    #---
    @arc = 0
    @parabola = {}
    @f = 0
    @arc_y = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return false
  end  
  
  #--------------------------------------------------------------------------
  # new method: use_8d?
  #--------------------------------------------------------------------------
  def use_8d?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: use_hb?
  #--------------------------------------------------------------------------
  def use_hb?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: use_cbs?
  #--------------------------------------------------------------------------
  def use_cbs?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: emptyview?
  #--------------------------------------------------------------------------
  def emptyview?
    return SYMPHONY::View::EMPTY_VIEW
  end
  
  #--------------------------------------------------------------------------
  # new method: battler
  #--------------------------------------------------------------------------
  def battler
    self.actor? ? self.actor : self.enemy
  end
  
  #--------------------------------------------------------------------------
  # new method: use_custom_charset?
  #--------------------------------------------------------------------------
  def use_custom_charset?
    if $imported["BattleSymphony-8D"]; return true if use_8d?; end
    if $imported["BattleSymphony-HB"]; return true if use_hb?; end
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_start
  #--------------------------------------------------------------------------
  alias bes_on_battle_start on_battle_start
  def on_battle_start
    reset_position
    #---
    bes_on_battle_start
    #---
    return if self.actor? && !$game_party.battle_members.include?(self)
    set_default_position
  end
  
  #--------------------------------------------------------------------------
  # new method: set_default_position
  #--------------------------------------------------------------------------
  def set_default_position
    @move_rate_x = 0
    @move_rate_y = 0
    #---
    @destination_x = self.screen_x
    @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    # Compatible
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_position
  #--------------------------------------------------------------------------
  def reset_position
    break_pose
  end
  
  #--------------------------------------------------------------------------
  # new method: break_pose
  #--------------------------------------------------------------------------
  def break_pose
    @direction = SYMPHONY::View::PARTY_DIRECTION
    @direction = Direction.opposite(@direction) if self.enemy?
    #---
    @pose = Direction.pose(@direction)
    #---
    @force_pose = false
    @reverse_pose = false
  end
  
  #--------------------------------------------------------------------------
  # new method: pose=
  #--------------------------------------------------------------------------
  def pose=(pose)
    @pose = pose
    return if self.actor? && !$game_party.battle_members.include?(self)
    self.sprite.correct_change_pose if SceneManager.scene.spriteset
  end
  
  #--------------------------------------------------------------------------
  # new method: can_collapse?
  #--------------------------------------------------------------------------
  def can_collapse?
    return false unless dead?
    unless actor?
      return false unless sprite.battler_visible
      array = [:collapse, :boss_collapse, :instant_collapse]
      return false if array.include?(sprite.effect_type)
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: weapons
  #--------------------------------------------------------------------------
  def weapons
    return []
  end
  
  #--------------------------------------------------------------------------
  # new method: equips
  #--------------------------------------------------------------------------
  def equips
    return []
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_state
  #--------------------------------------------------------------------------
  alias bes_add_state add_state
  def add_state(state_id)
    bes_add_state(state_id)
    #--- Fix Death pose ---
    return unless SceneManager.scene_is?(Scene_Battle)
    break_pose if state_id == death_state_id
  end
  
end # Game_Battler

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # overwrite method: use_sprite?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_default_position
  #--------------------------------------------------------------------------
  def set_default_position
    super
    return if @origin_x && @origin_y
    return unless $game_party.battle_members.include?(self)
    @origin_x = @screen_x = @destination_x = SYMPHONY::View::ACTORS_POSITION[index][0]
    @origin_y = @screen_y = @destination_y = SYMPHONY::View::ACTORS_POSITION[index][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_position
  #--------------------------------------------------------------------------
  def reset_position
    super
    @origin_x = @origin_y = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: screen_x
  #--------------------------------------------------------------------------
  alias bes_screen_x screen_x
  def screen_x
    emptyview? ? bes_screen_x : @screen_x
  end
  
  #--------------------------------------------------------------------------
  # alias method: screen_y
  #--------------------------------------------------------------------------
  alias bes_screen_y screen_y
  def screen_y
    emptyview? ? bes_screen_y : @screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    return if @origin_x && @origin_y
    @origin_x = @screen_x = SYMPHONY::View::ACTORS_POSITION[index][0]
    @origin_y = @screen_y = SYMPHONY::View::ACTORS_POSITION[index][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    index = $game_party.battle_members.index(self)
    return nil unless index
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return SceneManager.scene.spriteset.actor_sprites[index]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: perform_collapse_effect
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      @sprite_effect_type = :collapse unless self.use_custom_charset?
      Sound.play_actor_collapse
    end
  end
    
end # Game_Actor

#==============================================================================
# ■ Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    @origin_x ||= @screen_x
    @origin_y ||= @screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return super
  end  
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return SceneManager.scene.spriteset.enemy_sprites.reverse[self.index]
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id1
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return enemy.atk_animation_id1
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id2
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return enemy.atk_animation_id2
  end
  
end # Game_Enemy

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :effect_type
  attr_accessor :battler_visible
  
  #--------------------------------------------------------------------------
  # new method: pose
  #--------------------------------------------------------------------------
  alias bes_initialize initialize
  def initialize(viewport, battler = nil)
    bes_initialize(viewport, battler)
    correct_change_pose if @battler
    #---
    self.visible = false if SYMPHONY::View::EMPTY_VIEW && (@battler.nil? || @battler.actor?)
    #---
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    return unless SYMPHONY::Visual::BATTLER_SHADOW
    #---
    @charset_shadow = Sprite.new(viewport)
    @charset_shadow.bitmap = Cache.system("Shadow")
    @charset_shadow.ox = @charset_shadow.width / 2
    @charset_shadow.oy = @charset_shadow.height
  end
  
  #--------------------------------------------------------------------------
  # new method: pose
  #--------------------------------------------------------------------------
  def pose
    @battler.pose
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias bes_update update
  def update
    bes_update
    #---
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    return unless SYMPHONY::Visual::BATTLER_SHADOW
    #---
    @charset_shadow.opacity = self.opacity
    @charset_shadow.visible = self.visible
    @charset_shadow.x = self.x + (self.mirror ? 0 : - 2)
    @charset_shadow.y = self.y + 2
    @charset_shadow.z = self.z - 1
    #---
    @charset_shadow.opacity = 0 if @battler.nil?
  end
  
  #--------------------------------------------------------------------------
  # alias method: dispose
  #--------------------------------------------------------------------------
  alias bes_dispose dispose
  def dispose
    bes_dispose
    dispose_shadow
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_shadow
  #--------------------------------------------------------------------------
  def dispose_shadow
    @charset_shadow.dispose if @charset_shadow
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_bitmap
  #--------------------------------------------------------------------------
  alias bes_update_bitmap update_bitmap
  def update_bitmap
    correct_change_pose if @timer.nil?
    @battler.use_charset? ? update_charset : bes_update_bitmap
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_origin
  #--------------------------------------------------------------------------
  alias bes_update_origin update_origin
  def update_origin
    @battler.update_visual
    @battler.use_charset? ? update_charset_origin : bes_update_origin
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset
  #--------------------------------------------------------------------------
  def update_charset
    @battler.set_default_position unless pose
    #---
    update_charset_bitmap
    update_src_rect
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_change_pose
  #--------------------------------------------------------------------------
  def correct_change_pose
    @pattern = 1
    @timer = 15
    @back_step = false
    @last_pose = pose
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset_origin
  #--------------------------------------------------------------------------
  def update_charset_origin
    if bitmap
      self.ox = @cw / 2
      self.oy = @ch
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: graphic_changed?
  #--------------------------------------------------------------------------
  def graphic_changed?
    @character_name != @battler.character_name ||
    @character_index != @battler.character_index
  end
  
  #--------------------------------------------------------------------------
  # new method: set_character_bitmap
  #--------------------------------------------------------------------------
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset_bitmap
  #--------------------------------------------------------------------------
  def update_charset_bitmap
    if graphic_changed?
      @character_name = @battler.character_name
      @character_index = @battler.character_index
      set_character_bitmap
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_src_rect
  #--------------------------------------------------------------------------
  def update_src_rect
    @timer -= 1
    if @battler.force_pose
      array = []
      array = Direction.index_8d(pose) if $imported["BattleSymphony-8D"] && @battler.use_8d?
      if !@battler.reverse_pose && @pattern < 2 && @timer <= 0
        @pattern += 1
        @timer = array[2].nil? ? 15 : array[2]
      elsif @battler.reverse_pose && @pattern > 0 && @timer <= 0
        @pattern -= 1
        @timer = array[2].nil? ? 15 : array[2]
      end
    else
      #--- Quick Fix
      @pattern = 2 if @pattern > 2
      @pattern = 0 if @pattern < 0
      #--- End
      if @timer <= 0
        @pattern += @back_step ? -1 : 1
        @back_step = true if @pattern >= 2
        @back_step = false if @pattern <= 0
        @timer = 15
      end
    end
    #---
    @battler.break_pose unless pose
    direction = Direction.direction(pose)
    character_index = @character_index
    #---
    if $imported["BattleSymphony-8D"] && @battler.use_8d?
      array = Direction.index_8d(pose)
      character_index = array[0]
      direction = array[1]
    end
    sx = (character_index % 4 * 3 + @pattern) * @cw
    sy = (character_index / 4 * 4 + (direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: revert_to_normal
  #--------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
  end
  
  #--------------------------------------------------------------------------
  # alias method: animation_set_sprites
  # Make Animation Opacity independent of Sprite Opacity
  #--------------------------------------------------------------------------
  alias bes_animation_set_sprites animation_set_sprites
  def animation_set_sprites(frame)
    bes_animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.opacity = cell_data[i, 6]
    end
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :actor_sprites
  attr_accessor :enemy_sprites
  
  #--------------------------------------------------------------------------
  # overwrite method: create_actors
  # Fixed Large Party.
  #--------------------------------------------------------------------------
  def create_actors
    max_members = $game_party.max_battle_members
    @actor_sprites = Array.new(max_members) { Sprite_Battler.new(@viewport1) }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_actors
  # Fixed Change Party.
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      party_member = $game_party.battle_members[i]
      if party_member != sprite.battler
        sprite.battler = $game_party.battle_members[i]
        #---
        if party_member
          party_member.reset_position
          party_member.correct_origin_position
          party_member.break_pose if party_member.dead?
        end
        sprite.init_visibility if sprite.battler && !sprite.battler.use_custom_charset?
      end
      sprite.update
    end
  end
  
end # Spriteset_Battle