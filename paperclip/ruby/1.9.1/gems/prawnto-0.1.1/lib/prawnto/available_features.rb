unless defined? ::Rails::VERSION
  module Rails
    module VERSION
      MAJOR = 2
      MINOR = 0
      TINY = 0
      PRE = nil

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')
    end
  end
end

def base_class_for_template_handler_required?
  ::Rails::VERSION::MAJOR < 3
end

def template_should_include_compilable?
  ::Rails::VERSION::MAJOR < 3
end

def template_has_class_level_call_method?
  ::Rails::VERSION::MAJOR > 3 || (::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1)
end

def class_attribute_supported?
  ::Rails::VERSION::MAJOR >= 3
end