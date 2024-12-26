module AresMUSH
  module Magic
    class FatigueHealCmd
      include CommandHandler


      def check_errors
        return "You're not in combat" if !enactor.combat
      end

      def handle
        combat = enactor.combat
        
        if (combat.organizer != enactor)
          client.emit_failure t('fs3combat.only_organizer_can_do')
          return
        end

        combat.combatants.each do |c|
          puts c.name
          Magic.reset_magic_energy(c.associated_model)
        end
        client.emit_success "All combatants' mana restored to full."

      end
    end
  end
end
