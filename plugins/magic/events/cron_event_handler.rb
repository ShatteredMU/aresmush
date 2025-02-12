module AresMUSH
  module Magic
    class MagicCronEventHandler

      def on_event(event)
        shield_cron = Global.read_config("magic", "shield_cron")
        if Cron.is_cron_match?(shield_cron, event.time)
          Global.logger.debug "Magic shields expiring."

          Character.all.each do |c|
            shields = c.magic_shields
            shields.each do |shield|
              shield.delete
            end
          end
        end

        potion_cron = Global.read_config("magic", "potion_cron")
        if Cron.is_cron_match?(potion_cron, event.time)
          Global.logger.debug "Potion creation time updating"

          Character.all.each do |c|
            Magic.update_potion_hours(c)
          end
        end

        energy_cron = Global.read_config("magic", "energy_cron")
        if Cron.is_cron_match?(energy_cron, event.time)
          Global.logger.debug "Magic energy updating."

          Character.all.each do |c|
            Magic.magic_energy_cron(c)
          end
        end

      end

    end
  end
end
