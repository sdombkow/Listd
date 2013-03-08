module Prawnto
  module TemplateHandlers
    class Dsl < Base
      def self.call(template)
        <<-RUBY
          _prawnto_compile_setup(true)
          pdf = Prawn::Document.new(@prawnto_options[:prawn])
          pdf.instance_eval do
            #{template.source}
          end
          pdf.render
        RUBY
      end
    end
  end
end


