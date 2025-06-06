module AresMUSH
  module FS3Combat
    class CombatHudTemplate < ErbTemplateRenderer


      attr_accessor :combat

      def initialize(combat)
        @combat = combat
        super File.dirname(__FILE__) + "/hud.erb"
      end

      def format_name(c)
        color = Magic.get_fatigue_level(c.associated_model)[:color]
        "#{color}#{c.name}%xn"
      end

      def organizer
        t('fs3combat.combat_hud_organizer', :org => @combat.organizer.name)
      end

      def title
        scene = @combat.scene ? @combat.scene.id : t('global.none')
        t('fs3combat.combat_hud_header', :num => @combat.id, :scene => scene)
      end

      def teams
        @combat.active_combatants.sort_by{|c| c.team}.group_by {|c| c.team}
      end


      def format_action(c)
        action = c.action ? c.action.print_action_short : "----"
        "#{action} #{format_stance(c)}"
      end

      def format_stance(c)
        case c.stance
        when "Normal"
          text = ""
        else
          text = "(#{c.stance[0,3].upcase})"
        end

        if (c.is_in_vehicle?)
          if (c.piloting)
            text << "(plt)"
          else
            text << "(pas)"
          end
        end
        #EM Changes
        if (c.expanded_mount_type)
        #/EM Changes
          text << "(mnt)"
        end

        text
      end

      def pilot(v)
        v.pilot ? v.pilot.name : t('fs3combat.no_pilot')
      end

      def passengers(v)
        v.passengers.map { |p| p.name }.join(",")
      end

      def non_combatants
        @combat.non_combatants.map { |c| c.name}.join(", ")
      end

      def format_vehicle(c)
        if (c.piloting)
          text = t('fs3combat.piloting_hud', :vehicle => c.piloting.name)
        elsif (c.riding_in)
          text = t('fs3combat.passenger_hud', :vehicle => c.riding_in.name)
        else
         text =  ""
        end
        text
      end

      def format_damage(c)
        return "%xh%xr#{t('fs3combat.ko_status')}%xn" if c.is_ko
        damage_mod = FS3Combat.total_damage_mod(c.associated_model)
        FS3Combat.print_damage(damage_mod)
      end

      def format_weapon(c)
        weapon = "#{c.weapon}"

        if (c.max_ammo > 0)
          notes = " (#{c.ammo})"
        else
          notes = ""
        end

        "#{weapon}#{notes}"
      end

      def team_name(team)
        name = @combat.team_name(team)
        if (name)
          "#{team} (#{name})"
        else
          team
        end
      end
    end
  end
end