
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_target "build-files" do |target|
	target.provides "Build/Files" do
		define "copy.files", Rule do
			input :source, multiple: true
			
			parameter :prefix
			
			output :files, implicit: true, multiple: true do |arguments|
				arguments[:source].to_paths.rebase(arguments[:prefix])
			end
			
			apply do |arguments|
				arguments[:source].each do |path, root|
					path = Pathname(path)
					
					relative_path = Pathname(path).relative_path_from(Pathname(root)).to_s
					destination_path = Pathname(arguments[:prefix]) + relative_path
				
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
	end
end
