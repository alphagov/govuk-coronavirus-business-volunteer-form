require "fileutils"

def replace_meta_enums json
  json.each do |key, value|
    if (key == "enum") && value.any? { |member| member.start_with?("meta_i18n_enum:") }
      if value.size > 1
        throw ArgumentError("A meta enum should have a length of one. Found: #{value}")
      end
      json["enum"] = I18n.t(value.first.split(":", 2).last).map { |_, option| option[:label] }
    elsif value.class == Hash
      replace_meta_enums value
    elsif value.class == Array
      value.each do |member|
        handle_array member
      end
    end
  end
end

def handle_array member
  if member.class == FalseClass
    replace_meta_enums member
  elsif member.class == Array
    member.each do |nested_member|
      handle_array nested_member
    end
  end
end

desc "Generate json schema from locale and meta schema files"
task "generate-schema" => :environment do
  schema = replace_meta_enums JSON.parse(File.read(Rails.root.join("config/form_response_meta_schema.json")))
  schema.delete("description")
  FileUtils.mkdir_p "config/schemas"
  File.open("config/schemas/form_response.json", "w") do |f|
    f.write(JSON.pretty_generate(schema))
  end
end
