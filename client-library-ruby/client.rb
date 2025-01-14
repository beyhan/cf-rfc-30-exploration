require 'oj'

def detect_json_type(json_data)
    case json_data
    when Hash
        "Hash"
    when Array
        "Array"
    when String
        "String"
    when Integer, Float
        "Number"
    when TrueClass, FalseClass
        "Boolean"
    when NilClass
        "Null"
    else
        "Unknown"
    end
end

def process_json_files(directory)
    Dir.glob(File.join(directory, '*')) do |file_path|
        begin
            parsed_data = Oj.load(File.read(file_path))
            json_type = detect_json_type(parsed_data)
            puts "#{File.join("service-binding-root", File.basename(file_path))} - #{json_type}"
        rescue Oj::ParseError => e
            puts "Error parsing file #{File.basename(file_path)}: #{e.message}"
        end
    end
end

if __FILE__ == $0
    binding_name = ARGV.include?('--read_json') ? "foo-json" : "foo"
    process_json_files(File.join(__dir__,"..", "service-binding-root", binding_name))
end