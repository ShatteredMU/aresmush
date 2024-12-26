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
        end
  
        def handle

          combat = enactor.combat
  
          if (combat.organizer != enactor)
            client.emit_failure t('fs3combat.only_organizer_can_do')
            return
          end
  
          Magic.refund_magic_energy(self.target.combatant.associated_model, self.spell, self.success)
          
          client.emit_success t('magic.fatigue_refunded', :name => self.target.name, :spell => self.spell)
  
        end
      end
    end
  end
