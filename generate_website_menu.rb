#!/usr/bin/env ruby

# export RUBYOPT="-KU -E utf-8:utf-8"
require 'optparse'
require 'erb'
require 'logger'

# Entry of menu/title
MenuEntry = Struct.new(:title, :level, :items, :parent)

# Logger
LOGGER = Logger.new($stdout)

# Build template data class.
class MenuItemErb
  def initialize(title, items, template, level)
    @title = title
    @items = []
    @erb = ERB.new(template)
    @nb_items = items.length
    @level = level

    items.each do |item|     
      @items.push(MenuItemErb.new(item.title, item.items, template, level + 1))
    end
  end

  def parse_items()
    data = ''

    @items.each do |item|
      data = data + item.parse()
    end

    data
  end

  def parse()
    @erb.result(self.binding)
  end

  def title()
    @title
  end

  def items()
    @items
  end

  def nb_items()
    @nb_items
  end

  def is_root()
    @level == 0
  end
end

# Find parent from menu
def find_parent(menu, level)
  parent = nil

  while parent == nil
    if menu.level == level
      parent = menu.parent
    else
      menu = menu.parent
    end
  end  

  parent
end

# Return root menu
def find_root_menu(menu)
    # Go to root menu
    while menu.parent != nil do
      menu = menu.parent
    end
  
    menu
end

# Extract menu from one file
def extract_menu_from_one_file(filename) 
  menu = MenuEntry.new("", 0, [], nil)

  File.open(filename, "r:UTF-8")
  .each do |line|
    if m = line.match(/^(={1,6})\s+(.*)/)
      level = m[1].length
      title = m[2]

      if menu.level == level
        parent = menu.parent
        LOGGER.debug("Add item '#{title}' in current menu '#{parent.title}'")

        # If same level, add in current menu
        new_items = MenuEntry.new(title, level, [], parent)
        parent.items.push(new_items)

        LOGGER.debug("Switch to '#{title}' menu")

        menu = new_items
      elsif level > menu.level
        # New sub-menu
        if menu.level == 0
          LOGGER.debug("Initilize root menu with '#{title}'")

          menu.title = title
          menu.level = level
        else
          LOGGER.debug("Create sub-menu '#{title}' in current menu '#{menu.title}'")

          new_items = MenuEntry.new(title, level, [], menu)
          menu.items.push(new_items)
  
          LOGGER.debug("Switch to '#{title}' menu")

          menu = new_items
        end
      else
        menu = find_parent(menu, level)

        LOGGER.debug("Return to previous menu '#{menu.title}' to add menu '#{title}'")

        new_items = MenuEntry.new(title, level, [], menu)
        menu.items.push(new_items)
        menu = new_items
      end
    end
  end

  find_root_menu(menu)
end

def debug(data, level)
  offset = "  " * level

  puts "#{offset}- title:\"#{data.title}\""
  puts "#{offset}  level: #{data.level}"

  if data.parent != nil
    puts "#{offset}  parent: true"
  else
    puts "#{offset}  parent: false"
  end

  if data.items.length > 0
    puts "#{offset}  items: (#{data.items.length})"

    data.items.each do |item|
      debug(item, level + 1)
    end
  end
end

if __FILE__ == $0
  params = {}

  OptionParser.new do |opts|
    opts.on('-l', '--log LEVEL', 'Activate log level (debug, info, error)')
    opts.on('-t', '--template TEMPLATE', String, "Template to use to generate output")
    opts.on('-o', '--output [OUTPUT]', String, "Output filename. If - or missing, stdout is used")
    opts.on('-f', '--file FILE1,FILE2', Array, "Inputs file to read")
    opts.on('-h', '--help', "Print this help") do
      puts opts
      exit
    end
  end
  .parse!(into: params)

  log_level = (params[:log] == nil) ? '' : params[:log]

  case log_level.upcase
  when 'DEBUG'
    LOGGER.level = Logger::DEBUG
  when 'ERROR'
    LOGGER.level = Logger::ERROR
  else
    LOGGER.level = Logger::INFO
  end

  LOGGER.formatter = proc do |severity, datetime, _progname, msg|
    datefmt = datetime.strftime('%Y-%m-%dT%H:%M:%S.%6N')
    "[#{severity.ljust(4)}] - #{datefmt} - #{msg}\n"
  end

  if params[:file] == nil
    LOGGER.error("Missing filename in arguments!")
  elsif params[:template] == nil
      LOGGER.error("Missing template in arguments!")
  else
    params[:file].each do |file|
      if !File.exist?(file)
        LOGGER.error("File '#{file}' not found!")
      end
    end

    all_files_data = []

    # For each input file
    params[:file].each do |file|
      LOGGER.info("Read '#{file}' file...")
      menu = extract_menu_from_one_file(file)
      all_files_data.push(menu)
    end

    if LOGGER.debug?()
      debug(MenuEntry.new('root', 0, all_files_data, nil), 0)
    end

    # Read template file
    template = File.read(File.expand_path(params[:template]))

    # Create a fake root menu with all menu
    one_menu = MenuItemErb.new("We don't care", all_files_data, template, 0)

    LOGGER.info("Generate from template file '#{params[:template]}'...")

    output = (params[:output] == nil) ? '-' : params[:output]

    if output == '-'
      puts one_menu.parse
    else
      File.write(output, one_menu.parse)
    end
  end
end