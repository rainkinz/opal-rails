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
        @helper = ActionController::Base.helpers
      end


      def render(template, local_assigns = {})
        puts "Calling #{self.class} on template: '#{template}' locals #{local_assigns}"

        @view.controller.headers['Content-Type'] ||= 'text/javascript; charset=utf-8'

        src = 'Object.new.instance_eval {' <<
        JSON.parse(@view.assigns.to_json).map { |key, val| "@#{key} = #{val.inspect};" }.join <<
          JSON.parse(local_assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join <<
          template << '}'

          #%q:require 'opal-jquery'\n\nputs \"Adding message \#{@message}\"\n# Element.find('#chat').append(messages_html)\nElement.find('#chat').append(messages_html)\n\n: << '}'
        Opal.compile(src)
      end

      # def render(template, local_assigns = {})
      #   puts "Calling #{self.class} on template: '#{template}' locals #{local_assigns}"

      #   @view.controller.headers['Content-Type'] ||= 'text/javascript; charset=utf-8'

      #   js_local_assigns = JSON.parse(local_assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join
      #   js_assigns = JSON.parse(@view.assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join

      #   escaped = template.gsub(':', '\:')
      #   string = '%q:' + escaped + ':'
      #   js_src = 'Object.new.instance_eval {' << js_assigns << js_local_assigns << string << '}'
      #   binding.pry
      #   puts "Compiling: #{js_src}"
      #   # "Opal.compile('Object.new.instance_eval {' << #{js_assigns} << #{js_local_assigns} << #{string} << '}')"
      #   Opal.compile(js_src)

      # end


      # => "          def _app_views_messages_create_js_opal___3428366916889398280_70222354213540(local_assigns, output_buffer)\n            _old_virtual_path, @virtual_path = @virtual_path, \"messages/create\";_old_output_buffer = @output_buffer;messages_html = messages_html = local_assigns[:messages_html];;Opal.compile('Object.new.instance_eval {' << JSON.parse(@_assigns.to_json).map { |key, val| \"@\#{key} = \#{val.inspect};\" }.join << JSON.parse(local_assigns.to_json).map { |key, val| \"\#{key} = \#{val.inspect};\" }.join << %q:require 'opal-jquery'\n\nputs \"Adding message \#{@message}\"\n# Element.find('#chat').append(messages_html)\nElement.find('#chat').append(messages_html)\n\n\n: << '}')\n          ensure\n            @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer\n          end\n"
      # "Opal.compile('Object.new.instance_eval {' << JSON.parse(@_assigns.to_json).map { |key, val| \"@\#{key} = \#{val.inspect};\" }.join << JSON.parse(local_assigns.to_json).map { |key, val| \"\#{key} = \#{val.inspect};\" }.join << %q:require 'opal-jquery'\n\nputs \"Adding message \#{@message}\"\n# Element.find('#chat').append(messages_html)\nElement.find('#chat').append(messages_html)\n\n\n: << '}')"
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
