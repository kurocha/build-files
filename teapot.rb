
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_target "build-files" do |target|
	target.provides "Build/Files" do
		define Rule, "copy.file" do
			input :source_file
			output :destination_path
			
			apply do |arguments|
				fs.mkpath(File.dirname(arguments[:destination_path]))
				fs.cp(arguments[:source_file], arguments[:destination_path])
			end
		end
		
		define Rule, "copy.files" do
			# The input prefix where files are copied from:
			input :source, multiple: true
			
			# The output prefix where files will be copied to:
			parameter :prefix
			
			apply do |arguments|
				arguments[:source].each do |path|
					destination_path = arguments[:prefix] + path.relative_path
				
					if path.directory?
						unless destination_path.exist?
							fs.mkpath(destination_path)
						end
					else
						copy source_file: path, destination_path: destination_path
					end
				end
			end
		end
		
		define Rule, "copy.headers" do
			input :headers, multiple: true
			
			parameter :prefix, optional: true do |path, arguments|
				# We update the provided prefix as it is used to rebase the outputs:
				arguments[:prefix] = path || (environment[:install_prefix] + "include")
			end
			
			apply do |arguments|
				copy source: arguments[:headers], prefix: arguments[:prefix]
			end
		end
		
		define Rule, "copy.assets" do
			input :assets, multiple: true
			
			parameter :prefix, optional: true do |path, arguments|
				# We update the provided prefix as it is used to rebase the outputs:
				arguments[:prefix] = path || (environment[:install_prefix] + "share")
			end
			
			apply do |arguments|
				copy source: arguments[:assets], prefix: arguments[:prefix]
			end
		end
		
		define Rule, "copy.binaries" do
			input :binaries, multiple: true
			
			parameter :prefix, optional: true do |path, arguments|
				# We update the provided prefix as it is used to rebase the outputs:
				arguments[:prefix] = path || (environment[:install_prefix] + "bin")
			end
			
			apply do |arguments|
				copy source: arguments[:binaries], prefix: arguments[:prefix]
			end
		end
	end
end
