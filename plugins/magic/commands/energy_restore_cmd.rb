module AresMUSH
    module Magic
      class EnergyRestoreCmd
        include CommandHandler
  
        attr_accessor :target, percent

        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = Character.named(args.arg1)
          self.percent = titlecase_arg(args.arg2)
        end
  
        def check_errors
          return "You're not in combat." if !enactor.combat
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent.integer? == false
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent > 100
          return "Please specify a number between 1 and 100 for mana percentage." if self.percent < 1
        end
  
        def handle
          combat = enactor.combat
  
          if (combat.organizer != enactor)
            client.emit_failure t('fs3combat.only_organizer_can_do')
            return
          end
  
          target = Character.find_one_by_name(cmd.args)
          Magic.set_pc_energy(target, self.percent)
          
          client.emit_success "Mana restored."
  
        end
      end
    end
  end