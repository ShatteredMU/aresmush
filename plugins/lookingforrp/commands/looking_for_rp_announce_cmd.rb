module AresMUSH
    module LookingForRp
      class LookingForRpAnnounceCommand
        include CommandHandler

        attr_accessor :toggle, :name, :looking_for_rp_announce

        def parse_args
          self.toggle = (cmd.args)
        end
        
        def required_args
          [ self.toggle ]
        end
        
        def handle
          if self.toggle == "off"
            LookingForRp.announce_toggle_off(enactor)
            client.emit_success "You have toggled RP Requests announcements off."

          elsif self.toggle == "on"
            self.announce_toggle_on(enactor)
            client.emit_success "You have toggled RP Requests announcements on."
          end
        end
      end
  
    end
  end