
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "3.0"

define_target "build-files" do |target|
	target.provides "Build/Files" do
		define Rule, "copy.file" do
			input :source_file
			output :destination_path
			
			apply do |parameters|
				mkpath(File.dirname(parameters[:destination_path]))
				cp(parameters[:source_file], parameters[:destination_path])
			end
		end
		
		define Rule, "copy.files" do
			# The input prefix where files are copied from:
			input :source, multiple: true
			
			# The output prefix where files will be copied to:
			parameter :prefix
			
			apply do |parameters|
				parameters[:source].each do |path|
					destination_path = parameters[:prefix] + path.relative_path
				
					if path.directory?
						unless destination_path.exist?
							mkpath(destination_path)
						end
					else
						copy source_file: path, destination_path: destination_path
					end
				end
			end
		end
		
		define Rule, "copy.headers" do
			input :headers, multiple: true
			
			parameter :prefix, optional: true do |path, parameters|
				# We update the provided prefix as it is used to rebase the outputs:
				parameters[:prefix] = environment[:install_prefix] + path + "include"
			end
			
			apply do |parameters|
				copy source: parameters[:headers], prefix: parameters[:prefix]
			end
		end
		
		define Rule, "copy.assets" do
			input :assets, multiple: true
			
			parameter :prefix, optional: true do |path, parameters|
				# We update the provided prefix as it is used to rebase the outputs:
				parameters[:prefix] = environment[:install_prefix] + path + "share"
			end
			
			apply do |parameters|
				copy source: parameters[:assets], prefix: parameters[:prefix]
			end
		end
		
		define Rule, "copy.binaries" do
			input :binaries, multiple: true
			
			parameter :prefix, optional: true do |path, parameters|
				# We update the provided prefix as it is used to rebase the outputs:
				parameters[:prefix] = path || (environment[:install_prefix] + "bin")
			end
			
			apply do |parameters|
				copy source: parameters[:binaries], prefix: parameters[:prefix]
			end
		end
	end
end
