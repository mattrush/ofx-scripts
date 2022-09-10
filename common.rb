#!/usr/bin/env ruby

# requires open3

################
# functions
################

# misc shared functions

def run_local(x)
  Open3.popen2(x) do |i,o,wait_thru|
    a = o.read.split("\n")
    return a
  end
end

def include_deps(x)
  return false unless File.directory?(x)

  a = Dir.entries(x)
  a.delete('.')
  a.delete('..')

  a.each do |e|
    a.delete(e) if File.directory?("#{x}/#{e}")
    a.delete(e) unless e.match(/.*[.][r][b]$/,1)
  end

  a.each do |e|
    puts "[+][requiring][#{x}/#{e}]"
    require_relative "#{x}/#{e}" if e.match(/.*[.][r][b]$/,1)
  end
end

def find_files(x,y) # source_root as x, file name match pattern as y
  cmd = "find #{x} -type f -iname \"#{y}\""
  run_local(cmd)
end
#!/usr/bin/env ruby

# rendering functions

def delimit
  puts "-" * 24
end

def header(x)
  puts "[+]\u2500\u2500[#{x}]"
  puts " \u2502"
end

def bullet(x,y)
  puts " \u2514\u2500\u2500#{x} #{y}"
end
