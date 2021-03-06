module AresMUSH
  module Scenes
    class EditPlotRequestHandler
      def handle(request)
        plot = Plot[request.args[:id]]
        storyteller = Character[request.args[:storyteller_id]]
        enactor = request.enactor
        
        if (!plot || !storyteller)
          return { error: t('webportal.not_found') }
        end
        
        error = Website.check_login(request)
        return error if error
        
        if (!enactor.is_approved?)
          return { error: t('dispatcher.not_allowed') }
        end
        
        Global.logger.debug "Plot #{plot.id} edited by #{enactor.name}."
        
        [ :title, :summary ].each do |field|
          if (request.args[field].blank?)
            return { error: t('webportal.missing_required_fields') }
          end
        end
        
        plot.update(storyteller: storyteller)
        plot.update(summary: request.args[:summary])
        plot.update(content_warning: request.args[:content_warning])
        plot.update(title: request.args[:title])
        plot.update(description: request.args[:description])
        plot.update(completed: (request.args[:completed] || "").to_bool)
        {}
      end
    end
  end
end