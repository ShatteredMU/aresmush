module AresMUSH
    module LookingForRp
      class LookingForRpAnnounceCommand
        include CommandHandler

        attr_accessor :toggle, :name

        def parse_args
          self.toggle = (cmd.args)
        end
        
        def required_args
          [ self.toggle ]
        end
        
        def check_toggle
          return self.toggle.validate
        end
    
        def handle
          if self.toggle == "off"
            LookingForRp.announce_toggle_off(enactor)
            client.emit_success "You have toggled RP Requests announcements off."
            

            end          
          end
        end
      end
  
    end
  end