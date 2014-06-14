
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_target "build-files" do |target|
	target.provides "Build/Files" do
		define Rule, "copy.files" do
			# The input prefix where files are copied from:
			input :source, multiple: true
			
			# The output prefix where files will be copied to:
			parameter :prefix
			
			# Compute the output files by rebasing them into the destination prefix:
			output :files, implicit: true, multiple: true do |arguments|
				arguments[:source].to_paths.rebase(arguments[:prefix])
			end
			
			apply do |arguments|
				arguments[:source].each do |path, root|
					destination_path = Pathname(arguments[:prefix]) + path.relative_path
				
					if path.directory?
						# Make a directory at the destination:
						fs.mkpath destination_path
					else
						# Make the path if it doesn't already exist:
						fs.mkpath destination_path.dirname
						
						# Copy the file to the destination:
						fs.cp(path, destination_path)
					end
				end
			end
		end
		
		define Rule, "copy.headers" do
			input :headers, multiple: true
			
			# We copy headers into a prefix + "include" directory:
			parameter :prefix do |path|
				path + "include"
			end
			
			output :files, implicit: true, multiple: true do |arguments|
				arguments[:headers].to_paths.rebase(arguments[:prefix] + "include")
			end
			
			apply do |arguments|
				copy source: arguments[:headers], prefix: arguments[:prefix]
			end
		end
	end
end
