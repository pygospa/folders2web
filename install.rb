# Attempt at an INSTALL script for researchr. This will ask for key paths and some info, and fill out settings.rb
# (overwritten every time it is run), insert the correct path in keyboard_maestro.dist.kmmacros and save as
# import_into_keyboard_maestro.kmmacros, and search and replace the title in wiki/conf/local.php if it exists

# constants
$:.push(File.dirname($0))
require 'utility-functions'
require 'pashua'
include Pashua

questions = [
  ["Wiki_path","Path to your wiki installation", "/Library/WebServer/Documents/wiki",:directory],
  ["PDF_path","Directory where BibDesk stores the PDFs","#{Home_path}/Documents/Bibdesk",:directory],
  ["Bibliography","The database file that BibDesk uses (typically called Bibliography.bib)","",:file],
  ["Downloads_path","Directory where you store your downloads","#{Home_path}/Downloads",:directory],
  ["Internet_path","URL to your wiki when it's on the server (for example http://reganmian.net/wiki)","http://",:text],
  ["Wiki_title","The title of your wiki (for the RSS feed)","My Research Wiki",:text],
  ["Wiki_desc","The description of your wiki (for the RSS feed)","Raw research notes and article annotations",:textbox]
]

pash = ""
questions.each do |q|
  case q[3]
  when :directory
    pash << "#{q[0]}.type = openbrowser\n#{q[0]}.filetype = directory\n"
  when :file  
    pash << "#{q[0]}.type = openbrowser\n#{q[0]}.filetype = bib\n"
  when :text
    pash << "#{q[0]}.type = textfield\n"
  when :textbox
    pash << "#{q[0]}.type = textbox\n"
  end
  pash << "#{q[0]}.default = #{q[2]}\n#{q[0]}.label = #{q[1]}\n"    

end
pash << "cancel.type = cancelbutton \ncancel.label = Cancel \ncancel.tooltip = Closes this window without taking action\n" 

answers = pashua_run pash

# if cancel
if answers['cancel'] == "1"
  growl "Exiting without writing config. You can rerun this program at any time."
  exit(0)
end

settings = "# Settings generated automatically by install.rb. You can modify these manually, or rerun install.rb\n"
settings << "# If you rerun install.rb, this file will be overwritten. \n\n"
answers.each do |x|
  settings << "#{x[0]} = \"#{x[1]}\"\n"
end

# add some derived paths
settings << 'Wikipages_path = "#{Wiki_path}/data/pages"
Wikimedia_path = "#{Wiki_path}/data/media/pages"
JSON_path = "#{Wiki_path}/lib/plugins/dokuresearchr/json.tmp"' << "\n"

# write the settings file
File.write("#{Script_path}/settings.rb", settings)

# modify the path in the Keyboard Maestro macros
File.replace("#{Script_path}/keyboard_maestro.dist.kmmacros", "/Users/Stian/src/folders2web", Script_path, "#{Script_path}/import_to_keyboard_maestro.kmmacros")

# modify the title in the wiki 
if File.exists?("#{Script_path}/wiki/conf/local.php")
  title = Regexp.new("\\$conf\\[\\'title\\'\\](.+?)$")
  a = File.replace("#{Script_path}/wiki/conf/local.php", title, "$conf['title'] = \"#{answers["Wiki_desc"]}\";")
end

growl "Your settings have been modified. You can rerun this at any point. "