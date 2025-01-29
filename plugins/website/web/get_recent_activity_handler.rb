module AresMUSH
  module Website
    class GetRecentActivityRequestHandler
      def handle(request)
        enactor = request.enactor
        error = Website.check_login(request, true)
        return error if error

        Website.recent_activity(enactor)
      end
    end
  end
end