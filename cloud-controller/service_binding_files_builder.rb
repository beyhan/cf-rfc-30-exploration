require 'oj'
require 'fileutils'

class ServiceBindingFilesBuilder

    def build(write_json)
        sb_hash = Oj.load(File.read(File.join(__dir__,"..", "service-broker", 'binding-content')), symbol_keys: true)
        service_binding_files = {}
        creadential_types = {}
        metadata_types = {}

        name = sb_hash[:name]
        # add the credentials first
        sb_hash.delete(:credentials)&.each { |k, v| add_file(service_binding_files, creadential_types, name, k.to_s, v, write_json) }
        # add the rest of the hash; already existing credential keys are overwritten
        # VCAP_SERVICES attribute names are transformed (e.g. binding_guid -> binding-guid)
        sb_hash.each { |k, v| add_file(service_binding_files, metadata_types, name, transform_vcap_services_attribute(k.to_s), v, write_json) }

        binding_folder_name = write_json ? "#{name}-json" : name
        write_files(service_binding_files, binding_folder_name)
        write_metadata_file(creadential_types, metadata_types, binding_folder_name) unless write_json
        write_vcap_services_file(Oj.load(File.read(File.join(__dir__,"..", "service-broker", 'binding-content')))) unless write_json
    end

    private

    def write_vcap_services_file(vcap_services_hash)
        File.write(File.join(__dir__, "..", "service-binding-root", ".vcap_services"), Oj.dump(vcap_services_hash, mode: :compat, indent: 2))
    end

    def write_metadata_file(creadential_types, metadata_types, binding_folder_name)
        metadata_content = {
            metaDataProperties: metadata_types.map { |k, v| { name: k, format: v } },
            credentialProperties: creadential_types.map { |k, v| { name: k, format: v } }
        }
        File.write(File.join(__dir__, "..", "service-binding-root", binding_folder_name, ".metadata"), Oj.dump(metadata_content, mode: :compat, indent: 2))
    end

    def write_files(service_binding_files, binding_folder_name)
        puts "Writing files to service-binding-root/#{binding_folder_name}"
        service_binding_files.each do |file_name, content|
            FileUtils.mkdir_p(File.join(__dir__, "..", "service-binding-root", binding_folder_name))
            File.write(File.join(__dir__,"..","service-binding-root", binding_folder_name, File.basename(file_name)), content)
        end
    end

    def add_file(service_binding_files, file_types, name, key, value, write_json)
        path = "#{name}/#{key}"
        content = if write_json
                        Oj.dump(value, mode: :compat)
                  else
                      if value.is_a?(String)
                        file_types[key] = "text"
                        value
                      else
                        file_types[key] = "json"
                        Oj.dump(value, mode: :compat)
                      end
                  end

        service_binding_files[path] = content
    end


    def transform_vcap_services_attribute(name)
        if %w[binding_guid binding_name instance_guid instance_name syslog_drain_url volume_mounts].include?(name)
            name.tr('_', '-')
        else
            name
        end
    end
end

if __FILE__ == $0
    builder = ServiceBindingFilesBuilder.new
    builder.build(ARGV.include?('--write_json'))
end