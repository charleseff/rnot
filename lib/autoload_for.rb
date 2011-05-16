require 'active_support/core_ext'

class AutoloadFor
  def self.autoload_for(dir)
    Dir.glob(File.join(dir, "**/")).each do |inner_dir|
      dir_to_modulize = inner_dir.split("#{dir}/")[1]
      eval "module ::#{dir_to_modulize.chop.camelize}; end" if dir_to_modulize
    end

    Dir.glob(File.join(dir, '**', '*.rb')).each do |file|
      split = file.split("#{dir}/")[1].split('/')
      class_symbol = "#{split.last.chomp('.rb').camelize}".to_sym
      if (split.size > 1)
        the_module = eval(split[0, split.size-1].join('/').camelize)
        the_module.autoload class_symbol, file
      else
        ::Object.autoload class_symbol, file
      end
    end
  end
end