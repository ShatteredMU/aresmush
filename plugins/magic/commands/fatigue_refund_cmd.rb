module AresMUSH
    module Magic
      class FatigueRefundCmd
        include CommandHandler
        #fatigue/refund <name>=<spell>/<fail>
        attr_accessor :target_name, :spell, :success, :target

        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_optional_arg3)
          self.target = FS3Combat.find_named_thing(args.arg1, enactor)
          self.spell = titlecase_arg(args.arg2)
          self.success = titlecase_arg(args.arg3)
        end
  
        def check_errors
          return "You're not in combat." if !enactor.combat
          spell_list = Global.read_config("spells")
          return t('magic.not_spell') if !spell_list.include?(self.spell)
          return "That is not a valid target." if !self.target
        end
  
        def handle
          Global.logger.debug self.success
          combat = enactor.combat
  
          if (combat.organizer != enactor)
            client.emit_failure t('fs3combat.only_organizer_can_do')
            return
          end
  
          Magic.refund_magic_energy(self.target.combatant.associated_model, self.spell, self.success)
          if self.success == "Fail"
            then client.emit_success t('magic.fatigue_refunded_fail', :name => self.target.name, :spell => self.spell)
          end
          elsif !self.success 
            then client.emit_success t('magic.fatigue_refunded', :name => self.target.name, :spell => self.spell)
          end
        end
      end
    end
  end
