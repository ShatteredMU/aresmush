module AresMUSH
  module Magic
    class AddSceneSpellRequestHandler
      def handle(request)
        scene = Scene[request.args[:scene_id]]
        enactor = request.enactor
        pose_char = request.args[:pose_char]
        caster = pose_char ? Character[pose_char] : request.enactor
        spell_string = request.args[:spell_string]
        target_name_arg = request.args[:target_name]
        mod = request.args[:mod]
        if !target_name_arg.blank?
          has_target = true
        end

        puts request.args

        if (!scene)
          return { error: t('webportal.not_found') }
        end

        error = Website.check_login(request)
        return error if error

        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.access_not_allowed') }
        end

        if (scene.completed)
          return { error: t('scenes.scene_already_completed') }
        end

        if !Magic.is_spell?(spell_string)
          return { error: t('magic.not_spell') }
        else
          spell = spell_string.titlecase
        end

        target_num = Global.read_config("spells", spell, "target_num")
        if !target_name_arg.blank?
          if !target_num
            return { error: t('magic.doesnt_use_target') }
          else
            target_name_string = target_name_arg
          end
        else
          target_name_string = caster.name
        end

        if !Magic.knows_spell?(caster, spell)
          return { error:  t('magic.dont_know_spell') }
        end

        targets = Magic.parse_spell_targets(target_name_string, )
        error = Magic.spell_target_errors(enactor, targets, spell)
        return { error: error } if error

        print_names = Magic.print_target_names(targets)

        success = Magic.roll_noncombat_spell(caster, spell, mod)
        messages = success[:messages]
        if success[:succeeds] == "%xgSUCCEEDS%xn"
          messages.concat Magic.cast_noncombat_spell(caster.name, targets, spell, mod, success[:result])
          Magic.handle_spell_cast_achievement(caster)
        else
          if target_name_arg.blank?
            messages.concat [t('magic.casts_spell', :name => caster.name, :spell => spell, :mod => mod, :succeeds => success[:succeeds])]
          else
            messages.concat [t('magic.casts_spell_on_target', :name => caster.name, :spell => spell, :mod => mod, :target => print_names, :succeeds => success[:succeeds])]
          end
        end
        messages.each do |msg|
          Scenes.add_to_scene(scene, msg)
          if (scene.room)
            scene.room.emit msg
          end
        end

        {
        }
      end
    end
  end
end
