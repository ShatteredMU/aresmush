module AresMUSH
    module Magic
      class EnergyRestoreCmd
        include CommandHandler
  
        attr_accessor :target_name, :percent, :target

        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = FS3Combat.find_named_thing(args.arg1, enactor)
          self.percent = trim_arg(args.arg2)
        end
  
        def check_errors
          return "You're not in combat." if !enactor.combat
          return "That is not a valid target." if !self.target
          # return "Please specify a number between 1 and 100 for mana percentage." if self.percent.integer? == false
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent.to_i > 100
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent.to_i < 1
        end
  
        def handle

          combat = enactor.combat
  
          if (combat.organizer != enactor)
            client.emit_failure t('fs3combat.only_organizer_can_do')
            return
          end
  
          Magic.set_pc_energy(self.target.combatant.associated_model, self.percent)
          
          client.emit_success t('magic.fatigue_set', :name => self.target.name, :percent => self.percent)
  
        end
      end
    end
  end