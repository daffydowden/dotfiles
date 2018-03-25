# Require basics
# ==============

# http://drnicutilities.rubyforge.org/map_by_method/
#require 'map_by_method'

# Dr Nic's gem inspired by
# http://redhanded.hobix.com/inspect/stickItInYourIrbrcMethodfinder.html
#require 'what_methods'

begin
  require 'awesome_print' 
  Pry.config.print = proc { |output, value| output.puts value.ai }
  AwesomePrint.pry!
rescue LoadError => err
  puts "no awesome_print :("
end

# Print information about any HTTP requests being made
require 'net-http-spy'

# Draw ASCII tables
begin
  require 'hirb'
rescue LoadError
  # Missing goodies, bummer
end

if defined? Hirb
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |output, value|
        Hirb::View.view_or_page_output(value) || @old_print.call(output, value)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end

# 'lp' to show method lookup path
require 'looksee/shortcuts'

# Pry Remote
# After installing pry-remote and requiring it in your code simply use binding.remote_pry 
# (instead of the usual binding.pry) and connect to the session from another terminal 
# using pry-remote. See https://github.com/mon-ouie/pry-remote

# Other
# ==============

# Default editor is Sublime text 2
Pry.config.editor = "nvim"
