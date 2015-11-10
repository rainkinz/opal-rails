module Opal
  module Rails
    class TemplateHandler

      def self.call(template)
        #new.call(template)
        "Opal::Rails::TemplateHandler.new(self).render(#{template.source.inspect}, local_assigns)"
      end

      def initialize(view)
        @view = view
        @controller = @view.controller
      end

      def render(template, local_assigns = {})
        @controller.headers['Content-Type'] ||= 'text/javascript; charset=utf-8'

        src = 'Object.new.instance_eval {' <<
          JSON.parse(@view.assigns.to_json).map { |key, val| "@#{key} = #{val.inspect};" }.join <<
          JSON.parse(local_assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join <<
          template << '}'
        Opal.compile(src)
      end

      # def call(template)
      #   binding.pry
      #   escaped = template.source.gsub(':', '\:')
      #   string = '%q:' + escaped + ':'
      #   puts "STRING: #{string}"
      #   puts "LOCAL ASSIGNS: #{local_assigns}"
      #   puts "ASSIGNS: #{assigns}"
      #   res = "Opal.compile('Object.new.instance_eval {' << #{assigns} << #{local_assigns} << #{string} << '}')"
      #   puts "RES: #{res}"
      #   res
      # end

      # private

      # def local_assigns
      #   <<-'RUBY'.strip
      #     JSON.parse(local_assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join
      #   RUBY
      # end

      # def assigns
      #   <<-'RUBY'.strip
      #     JSON.parse(@_assigns.to_json).map { |key, val| "@#{key} = #{val.inspect};" }.join
      #   RUBY
      # end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :opal, Opal::Rails::TemplateHandler
end
