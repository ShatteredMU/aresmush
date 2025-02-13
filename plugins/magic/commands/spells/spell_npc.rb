module AresMUSH
  module Magic
    class SpellNPCCmd
    #spell/npc npc/dice=spell/target
      include CommandHandler
      attr_accessor :name, :spell, :spell_list, :has_target, :args, :mod, :target, :target_name_string, :target_name, :npc, :dice

      def parse_args
        args = cmd.parse_args(/(?<npc>.+\w)\/(?<dice>\d+)\=(?<spell>[^+\-\/]+[^+\-\/\s])\s*?(\/(?<target>.*))?/)
        self.spell = titlecase_arg(args.spell)
        self.npc = titlecase_arg(args.npc)
        self.dice = args.dice.to_i

        if !args.target
          self.target_name_string = self.npc
          self.has_target = false
        else
          self.target_name_string = titlecase_arg(args.target)
          self.has_target = true
        end
      end

      def check_errors
        return t('magic.use_combat_spell') if enactor.combat
        spell_list = Global.read_config("spells")
        return t('magic.not_spell') if !spell_list.include?(self.spell)
        target_num = Global.read_config("spells", spell, "target_num")
        return t('magic.doesnt_use_target') if (self.has_target && !target_num)
        return nil
      end

      def handle
        targets = Magic.parse_spell_targets(self.target_name_string, !self.has_target)
        error = Magic.spell_target_errors(enactor, targets, spell)
        if error then return client.emit_failure error end
        print_names = Magic.print_target_names(targets)

        result = Magic.roll_npc_spell(self.npc, self.spell, self.dice)
        if result[:succeeds] == "%xgSUCCEEDS%xn"
          message = Magic.cast_noncombat_spell(self.npc, targets, spell, mod, result[:result])
          Magic.handle_spell_cast_achievement(enactor)
        else
          #Spell fails
          if !self.has_target
            message = [t('magic.casts_spell', :name => self.npc, :spell => spell, :mod => mod, :succeeds => result[:succeeds])]
          else
            message = [t('magic.casts_spell_on_target', :name => self.npc, :spell => spell, :mod => mod, :target => print_names, :succeeds => result[:succeeds])]
          end
        end



        # if success[:succeeds] == "%xgSUCCEEDS%xn"
        #   if heal_points
        #     message = Magic.cast_non_combat_heal(self.npc, self.target_name_string, self.spell, mod = nil)
        #   elsif Magic.spell_shields.include?(self.spell)
        #     message = Magic.cast_noncombat_shield("npc", self.npc, self.target_name_string, self.spell, mod = nil, success[:result])
        #   else
        #     if !self.has_target
        #       self.target_name_string = nil
        #     end
        #     message = Magic.cast_noncombat_spell(self.npc, self.target_name_string, self.spell, mod = nil, success[:result])
        #   end
        # else
        #   if !self.has_target
        #     message = [t('magic.casts_spell', :name => self.npc, :spell => spell, :mod => mod, :succeeds => success[:succeeds])]
        #   else
        #     if print_names == "no_target"
        #       print_names = self.npc
        #     end
        #     message = [t('magic.casts_spell_on_target', :name => self.npc, :spell => spell, :mod => mod, :target => print_names, :succeeds => success[:succeeds])]
        #   end
        # end
        message.each do |msg|
          enactor.room.emit msg
          if enactor.room.scene
            Scenes.add_to_scene(enactor.room.scene, msg)
          end
        end
      end

    end
  end
end
