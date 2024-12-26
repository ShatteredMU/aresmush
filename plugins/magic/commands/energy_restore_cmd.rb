module AresMUSH
    module Magic
      class EnergyRestoreCmd
        include CommandHandler
  
        attr_accessor :target_name, :percent, :target

        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = Character.named(args.arg1)
          self.percent = trim_arg(args.arg2)
        end
  
        def check_errors
          return "You're not in combat." if !enactor.combat
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent.integer? == false
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent > 100
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent < 1
        end
  
        def handle
          Login.emit_if_logged_in self.target
          Login.emit_if_logged_in self.percent
          combat = enactor.combat
  
          if (combat.organizer != enactor)
            client.emit_failure t('fs3combat.only_organizer_can_do')
            return
          end
  
          Magic.set_pc_energy(target, self.percent)
          
          client.emit_success "Mana restored."
  
        end
      end
    end
  end