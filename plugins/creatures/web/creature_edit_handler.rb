module AresMUSH
  module Creatures
    class CreatureEditRequestHandler
      def handle(request)
        creature = Creature.find_one_by_name(request.args[:id])
        enactor = request.enactor

        if (!creature)
          return { error: t('webcreature.not_found') }
        end

        error = Website.check_login(request, true)
        return error if error

        if (request.args[:name].blank? || request.args[:short_desc].blank?)
          return { error: t('webportal.missing_required_fields') }
        end

        if (!enactor.is_approved?)
          return { error: t('dispatcher.not_allowed') }
        end

        Global.logger.debug "Creature #{creature.id} (#{creature.name}) edited by #{enactor.name}. Request: #{request.args}"

          gm_names = request.args[:gms] || []
          creature.gms.replace []

          gm_names.each do |gm|
            gm = Character.find_one_by_name(gm.strip)
            if (gm)
              if (!creature.gms.include?(gm))
                Creatures.add_gm(creature, gm)
              end
            end
          end

          plot_ids = request.args[:plots] || []
          creature.plots.replace []

          plot_ids.each do |plot|
            plot = Plot.find_one_by_name(plot.strip)
            if (plot)
              Creatures.add_plot(portal, plot)
            end
          end


          sapient = (request.args[:sapient] || "").to_bool

          creature.update(name: request.args[:name])
          creature.update(pinterest: request.args[:pinterest].blank? ? nil : request.args[:pinterest])
          creature.update(found: request.args[:found].blank? ? nil : request.args[:found])
          creature.update(sapient: sapient)
          creature.update(traits: request.args[:traits].blank? ? nil : request.args[:traits])
          creature.update(combat: request.args[:combat].blank? ? nil : request.args[:combat])
          creature.update(society: request.args[:society].blank? ? nil : request.args[:society])
          creature.update(short_desc: request.args[:short_desc].blank? ? nil : request.args[:short_desc])
          creature.update(speed: request.args[:speed].blank? ? nil : request.args[:speed])
          creature.update(length: request.args[:length].blank? ? nil : request.args[:length])
          creature.update(height: request.args[:height].blank? ? nil : request.args[:height])
          creature.update(magical_abilities: request.args[:magical_abilities].blank? ? nil : request.args[:magical_abilities])
          creature.update(events: request.args[:events].blank? ? nil : request.args[:events])
          banner_image = Creatures.build_image_path(creature, request.args[:banner_image])
          profile_image = Creatures.build_image_path(creature, request.args[:profile_image])
          gallery = (request.args[:image_gallery] || '').split.map { |g| g.downcase }
          creature.update(image_gallery: gallery)
          creature.update(banner_image: banner_image)
          creature.update(profile_image: profile_image)

          Website.add_to_recent_changes('creature', t('creatures.creature_updated', :name => creature.name), { id: creature.id }, enactor.name)

          {}
      end
    end
  end
end
