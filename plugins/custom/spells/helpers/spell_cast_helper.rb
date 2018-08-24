module AresMUSH
  module Custom

    def self.cast_equip_armor(caster_combat, spell)
      succeeds = Custom.roll_combat_spell_success(caster_combat, spell)
      armor = Global.read_config("spells", spell, "armor")
      client = Login.find_client(caster_combat)
      if succeeds == "%xgSUCCEEDS%xn"
        caster_combat.update(armor_name: armor)
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      else
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      end
      FS3Combat.set_action(client, caster_combat, caster_combat.combat, caster_combat, FS3Combat::SpellAction, "")
    end

    def self.cast_equip_armor_specials(caster_combat, spell)
      succeeds = Custom.roll_combat_spell_success(caster_combat, spell)
      armor_specials = Global.read_config("spells", spell, "armor_specials")
      client = Login.find_client(caster)
      if succeeds == "%xgSUCCEEDS%xn"
        caster_combat.update(armor_specials: armor_specials)
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell)
        FS3Combat.set_action(client, caster_combat, caster.combat, caster_combat, FS3Combat::SpellAction, "")
      else
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      end
    end

    def self.cast_equip_weapon(enactor, caster_combat, spell)
      weapon = Global.read_config("spells", spell, "weapon")
      caster_combat.update(weapon_name: weapon)
        weapon_type = FS3Combat.weapon_stat(caster_combat.weapon, "weapon_type")
      armor = Global.read_config("spells", spell, "armor")
      is_stun = Global.read_config("spells", spell, "is_stun")
      if armor

      elsif is_stun

      elsif weapon_type == "Explosive"
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.will_cast_spell', :name => caster_combat.name, :spell => spell)
        FS3Combat.emit_to_combatant enactor.combatant, t('custom.target_aoe')
      elsif weapon_type == "Supressive"
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.will_cast_spell', :name => caster_combat.name, :spell => spell)
        FS3Combat.emit_to_combatant enactor.combatant, t('custom.target_suppress')
      else
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.will_cast_spell', :name => caster_combat.name, :spell => spell)
        FS3Combat.emit_to_combatant enactor.combatant, t('custom.target_attack')
      end
    end

    def self.cast_equip_weapon_specials(caster_combat, spell)
      weapon_specials = Global.read_config("spells", spell, "weapon_specials")
      succeeds = Custom.roll_combat_spell_success(caster_combat, spell)
      client = Login.find_client(caster_combat)
      if succeeds == "%xgSUCCEEDS%xn"
        caster_combat.update(weapon_specials: weapon_specials)
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell)
      else
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      end
      FS3Combat.set_action(client, caster_combat, caster_combat.combat, caster_combat, FS3Combat::SpellAction, "")
    end

    def self.cast_roll_spell(caster_combat, spell)
      succeeds = Custom.roll_combat_spell_success(caster_combat, spell)
      client = Login.find_client(caster_combat)
      if succeeds == "%xgSUCCEEDS%xn"
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      else
        FS3Combat.emit_to_combat caster_combat.combat, t('custom.casts_spell', :name => caster_combat.name, :spell => spell, :succeeds => succeeds)
      end
      FS3Combat.set_action(client, caster_combat, caster_combat.combat, caster_combat, FS3Combat::SpellAction, "")
    end

    def self.cast_noncombat_spell(caster, spell)
      school = Global.read_config("spells", spell, "school")
      client = Login.find_client(caster)
      Rooms.emit_to_room(caster.room, t('custom.casts_noncombat_spell', :name => caster.name, :spell => spell))
      die_result = FS3Skills.parse_and_roll(caster, school)
        success_level = FS3Skills.get_success_level(die_result)
        success_title = FS3Skills.get_success_title(success_level)
        message = t('fs3skills.simple_roll_result',
          :name => caster.name,
          :roll => school,
          :dice => FS3Skills.print_dice(die_result),
          :success => success_title
        )
        FS3Skills.emit_results message, client, caster.room, false
    end

    def self.cast_stun_spell(enactor, caster_combat, spell)
      client = Login.find_client(caster_combat)
      FS3Combat.emit_to_combat caster_combat.combat, t('custom.will_cast_spell', :name => caster_combat.name, :spell => spell)
      FS3Combat.emit_to_combatant enactor.combatant, t('custom.target_stun')
    end



  end
end