module AresMUSH
  module FS3Combat
    class PotionAction < CombatAction
      attr_accessor  :spell, :target, :names, :potion, :has_target
      def prepare

        if (self.action_args =~ /\//)
          #Uses 'spell' instead of potion for easy c/p. Spell == potion.
          self.spell = self.action_args.before("/")
          self.names = self.action_args.after("/")
          self.has_target = true
        else
          self.names = self.name
          self.spell = self.action_args
        end

        self.spell = self.spell.titlecase

        self.potion = Magic.find_potion_has(combatant.associated_model, self.spell) if !combatant.is_npc?

        error = self.parse_targets(self.names)
        return error if error
        return t('magic.dont_have_potion') if (!combatant.is_npc? && !self.potion)
        return t('magic.not_potion') if !Magic.is_potion?(self.spell)
        return t('fs3combat.only_one_target') if (self.targets.count > 1)
        targets.each do |target|
          heal_points = Global.read_config("spells", self.spell, "heal_points")
          wound = FS3Combat.worst_treatable_wound(target.associated_model)
          return t('magic.no_healable_wounds', :target => target.name) if (heal_points && wound.blank?)
        end

        targets.each do |target|
          # Don't let people waste a spell that won't have an effect
          wound = FS3Combat.worst_treatable_wound(target.associated_model)
          heal_points = Global.read_config("spells", self.spell, "heal_points")
          weapon = Global.read_config("spells", self.spell, "weapon")
          return t('magic.no_healable_wounds', :target => target.name) if (heal_points && wound.blank? && !weapon)
          energy_points = Global.read_config("spells", self.spell, "energy_points")
          return t('magic.cannot_spell_fatigue_heal_further', :name => target.name) if (energy_points && (target.associated_model.magic_energy >= (target.associated_model.total_magic_energy * 0.8)))
          # Check that weapon specials can be added to weapon
          weapon_specials_str = Global.read_config("spells", self.spell, "weapon_specials")
          if weapon_specials_str
            weapon_special_group = FS3Combat.weapon_stat(target.weapon, "special_group") || ""
            weapon_allowed_specials = Global.read_config("fs3combat", "weapon special groups", weapon_special_group) || []
            return t('magic.cant_cast_on_gear', :spell => self.spell, :target => target.name, :gear => "#{target.weapon} weapon") if !weapon_allowed_specials.include?(weapon_specials_str.downcase)
          end
          #Check that armor specials can be added to weapon
          armor_specials_str = Global.read_config("spells", self.spell, "armor_specials")
          if armor_specials_str
            armor_allowed_specials = FS3Combat.armor_stat(target.armor, "allowed_specials") || []
            return t('magic.cant_cast_on_gear', :spell => self.spell, :target => target.name, :gear => "#{target.armor} armor") if !armor_allowed_specials.include?(armor_specials_str)
          end
        end

        return nil
      end

      def print_action
        if self.has_target
          msg = t('magic.potion_action_target_msg_long', :name => self.name, :potion => self.spell, :target => print_target_names)
        else
          msg = t('magic.potion_action_msg_long', :name => self.name, :potion => self.spell)
        end
      end

      def print_action_short
        t('magic.potion_action_target_msg_short', :target => print_target_names)
      end

      def resolve
        messages = []
        weapon = Global.read_config("spells", self.spell, "weapon")
        weapon_specials_str = Global.read_config("spells", self.spell, "weapon_specials")
        armor = Global.read_config("spells", self.spell, "armor")
        armor_specials_str = Global.read_config("spells", self.spell, "armor_specials")
        heal_points = Global.read_config("spells", self.spell, "heal_points")
        is_shield = Global.read_config("spells", spell, "is_shield")
        lethal_mod = Global.read_config("spells", self.spell, "lethal_mod")
        attack_mod = Global.read_config("spells", self.spell, "attack_mod")
        defense_mod = Global.read_config("spells", self.spell, "defense_mod")
        init_mod = Global.read_config("spells", self.spell, "init_mod")
        spell_mod = Global.read_config("spells", self.spell, "spell_mod")
        stance = Global.read_config("spells", self.spell, "stance")
        roll = Global.read_config("spells", self.spell, "roll")
        rounds = Global.read_config("spells", self.spell, "rounds")
        energy_points = Global.read_config("spells", self.spell, "energy_points")

        succeeds = "%xgSUCCEEDS%xn"

        targets.each do |target|

          #Healing
          if heal_points
            wound = FS3Combat.worst_treatable_wound(target.associated_model)
            if (wound)
              if target.death_count > 0
                messages.concat [t('magic.potion_ko_heal', :name => self.name, :target => target.name, :potion => self.spell, :points => heal_points)]
              else
                messages.concat [t('magic.potion_heal', :name => self.name, :target => target.name, :potion => self.spell, :points => heal_points)]
              end
              FS3Combat.heal(wound, heal_points)
            else
              messages.concat [t('magic.potion_heal_no_effect', :name => self.name, :potion => self.spell)]
            end
            target.update(death_count: 0  )
          end

          if energy_points
            message = Magic.cast_fatigue_heal(self.name, target.associated_model, self.spell, true)
            # if combatant == target
            #   combatant.associated_model.update(magic_energy: target.associated_model.magic_energy)
            # end
            messages.concat message
          end

          #Equip Weapon
          if (weapon && weapon != "Spell")
            message = Magic.cast_weapon(combatant.name, combatant, target, self.spell, weapon, true)
            messages.concat message

          end

          #Equip Weapon Specials
          if weapon_specials_str
            message = Magic.cast_weapon_specials(combatant.name, combatant, target, self.spell, true)
            messages.concat message

            # weapon = target.weapon.before("+")
            # Magic.magic_weapon_specials(target, self.spell)
            # Magic.set_magic_weapon(target, weapon)
            # if (heal_points && wound)

            # elsif lethal_mod || defense_mod || attack_mod || spell_mod

            # else
            #   if target.name == combatant.name
            #     messages.concat [t('magic.potion', :name => self.name, :potion => self.spell)]
            #   else
            #     messages.concat [t('magic.potion_target', :name => self.name, :target => target.name, :potion => self.spell)]
            #   end
            # end
          end

          #Equip Armor
          if armor
            FS3Combat.set_armor(combatant, target, armor)
            if target.name == combatant.name
              messages.concat [t('magic.potion', :name => self.name, :potion => self.spell)]
            else
              messages.concat [t('magic.potion_target', :name => self.name, :target => target.name, :potion => self.spell)]
            end
          end

          #Equip Armor Specials
          if armor_specials_str
            armor_specials = armor_specials_str ? armor_specials_str.split('+') : nil
            FS3Combat.set_armor(combatant, target, target.armor, armor_specials)
            if target.name == combatant.name
              messages.concat [t('magic.potion', :name => self.name, :potion => self.spell)]
            else
              messages.concat [t('magic.potion_target', :name => self.name, :target => target.name, :potion => self.spell)]
            end
          end


          #Apply Mods
          puts "l #{lethal_mod} a #{attack_mod} s #{spell_mod} d #{defense_mod} i #{init_mod}"
          if lethal_mod || attack_mod || spell_mod || defense_mod || init_mod
            mod_msg = Magic.update_spell_mods(target, rounds, attack_mod, defense_mod, init_mod, lethal_mod, spell_mod)
            if target.name == combatant.name
              messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod_msg => mod_msg)]
            else
              messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod_msg => mod_msg)]
            end
          end


          #   target.update(magic_lethal_mod_counter: rounds)
          #   target.update(magic_lethal_mod: lethal_mod)
            # if target.name == combatant.name
            #   messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod => target.magic_lethal_mod, :type => "lethality")]
            # else
            #   messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod => target.magic_lethal_mod, :type => "lethality")]
            # end
          # end

          # if attack_mod
          #   target.update(magic_attack_mod: rounds)
          #   target.update(magic_attack_mod_counter: attack_mod)
          #   if target.name == combatant.name
          #     messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod => target.magic_attack_mod, :type => "attack")]
          #   else
          #     messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod => target.magic_attack_mod, :type => "attack")]
          #   end
          # end

          # if defense_mod
          #   target.update(magic_defense_mod_counter: rounds)
          #   target.update(magic_defense_mod: defense_mod)
          #   if target.name == combatant.name
          #     messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod => target.magic_defense_mod, :type => "defense")]
          #   else
          #     messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod => target.magic_defense_mod, :type => "defense")]
          #   end
          # end

          # if init_mod
          #   target.update(magic_init_mod: rounds)
          #   target.update(magic_init_mod_counter: attack_mod)
          #   if target.name == combatant.name
          #     messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod => target.magic_init_mod, :type => "attack")]
          #   else
          #     messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod => target.magic_init_mod, :type => "attack")]
          #   end
          # end

          # if spell_mod
          #   target.update(spell_mod_counter: rounds)
          #   target.update(spell_mod: spell_mod)
          #   if target.name == combatant.name
          #     messages.concat  [t('magic.potion_mod', :name => self.name, :potion => self.spell, :mod => target.spell_mod, :type => "spell")]
          #   else
          #     messages.concat  [t('magic.potion_mod_target', :name => self.name, :potion => self.spell, :target => target.name, :mod => target.spell_mod, :type => "spell")]
          #   end
          # end

          #Set Shields
          if is_shield == true
            #Potion shields default to strength (result) of 2
            message = Magic.cast_shield(combatant.name, target, self.spell, rounds, 2, is_potion = true)
            messages.concat message
          end

          #Roll
          if roll
            if target.name == combatant.name
              messages.concat [t('magic.potion', :name => self.name, :potion => self.spell)]
            else
              messages.concat [t('magic.potion_target', :name => self.name, :target => target.name, :potion => self.spell)]
            end
          end

          if !combatant.is_npc?
            potion = Magic.find_potion_has(combatant.associated_model, self.spell)
            potion.delete
          end

        end

        messages

      end
    end
  end
end
