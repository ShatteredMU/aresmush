module AresMUSH
  module Magic
    class PotionCreateCmd
      include CommandHandler
# potion/create <name> - Create a potion.

      attr_accessor :potions_creating, :potion_name

      def parse_args
        self.potion_name = titlecase_arg(cmd.args)
      end

      def check_errors
        return t('magic.no_potions_spell') if !Magic.knows_potion?(enactor)

        return t('fs3skills.not_enough_points') if enactor.luck < 1
        return t('magic.not_spell') if !Magic.is_spell?(cmd.args)
        return t('magic.not_potion') if !Magic.is_potion?(cmd.args)
        return nil
      end

      def handle
        enactor.spend_luck(1)
        spell_level = Global.read_config("spells", self.potion_name, "level")
        hours_to_create = spell_level * 48
        PotionsCreating.create(name: self.potion_name, hours_to_creation: hours_to_create, character: enactor)
        if hours_to_create < 24
          time = "#{hours_to_create} hours"
        else
          time = "#{hours_to_create / 24} days"
        end
        client.emit_success t('magic.begun_creating_potion', :potion_name => potion_name, :time => time)
        Magic.handle_potions_made_achievement(enactor)
      end






    end
  end
end
