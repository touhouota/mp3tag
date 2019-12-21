require "mp3info"
require "yaml"

config_path = Pathname.new("./config.yml")
config = YAML.safe_load(config_path.read, symbolize_names: true)
base_path = Pathname.new(config[:base_path])
mp3_list = Dir[base_path.join("*")].select{|file| File.extname(file).start_with? ".mp3"}

mp3_list.each do |mp3_path|
  p File.basename(mp3_path)
  Mp3Info.open(mp3_path) do |mp3|
    if mp3.hastag1?
      puts 'ID3v1 情報が見つかりました'
    end
    if mp3.hastag2?
      puts 'ID3v2 情報が見つかりました'
    end
  end
end
