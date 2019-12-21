require "mp3info"
require "yaml"
require "csv"

config_path = Pathname.new("./config.yml")
config = YAML.safe_load(config_path.read, symbolize_names: true)
base_path = Pathname.new(config[:base_path])
mp3_list = Dir[base_path.join("*")].select{|file| File.extname(file).start_with? ".mp3"}

csv_options = {
  headers: true,
  header_converters: ->(header) { header.to_sym }
}
master_csv = CSV.read(base_path.join(config[:csv_name]), csv_options)

mp3_list.each do |mp3_path|
  puts "処理中：#{File.basename(mp3_path)}"
  Mp3Info.open(mp3_path) do |mp3|
    next unless mp3.hastag2?

    index = master_csv.find_index{|row| row[:title] == File.basename(mp3_path, ".*")}
    next unless index

    info = master_csv[index]
    mp3.tag2[Mp3Info::TAG_MAPPING_2_3["title"]] = info[:title]
    mp3.tag2[Mp3Info::TAG_MAPPING_2_3["artist"]] = info[:vocal]
    mp3.tag2[Mp3Info::TAG_MAPPING_2_3["album"]] = info[:album]
    # グループ
    mp3.tag2["GPR1"] = info[:circle]
    mp3.tag2[Mp3Info::TAG_MAPPING_2_3["genre_s"]] = info[:original]
  end
end
