require "prawnto/available_features"

module Prawnto
  module ActionControllerMixin
    DEFAULT_PRAWNTO_OPTIONS = {:inline => true}

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      if class_attribute_supported?
        def self.extended(cls)
          cls.send(:class_attribute, :prawn_options)
          cls.send(:class_attribute, :prawnto_options)
        end
      else
        def prawn_options=(options)
          write_inheritable_hash(:prawn_options, options)
        end

        def prawn_options
          read_inheritable_attribute(:prawn_options)
        end

        def prawnto_options=(options)
          write_inheritable_hash(:prawnto_options, options)
        end

        def prawnto_options
          read_inheritable_attribute(:prawnto_options)
        end
      end

      def prawnto(options)
        prawn_options, prawnto_options = breakdown_prawnto_options options
        self.prawn_options = prawn_options
        self.prawnto_options = prawnto_options
      end

      private

      def breakdown_prawnto_options(options)
        prawnto_options = options.dup
        prawn_options = (prawnto_options.delete(:prawn) || {}).dup
        [prawn_options, prawnto_options]
      end
    end

    def prawnto(options)
      @prawnto_options ||= DEFAULT_PRAWNTO_OPTIONS.dup
      @prawnto_options.merge! options
    end

    private

    def compute_prawnto_options
      @prawnto_options ||= DEFAULT_PRAWNTO_OPTIONS.dup
      @prawnto_options[:prawn] ||= {}
      @prawnto_options[:prawn].merge!(self.class.prawn_options || {}) { |k, o, n| o }
      @prawnto_options.merge!(self.class.prawnto_options || {}) { |k, o, n| o }
      @prawnto_options
    end
  end
end


