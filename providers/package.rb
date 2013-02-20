action :install do
  status = package_status(new_resource.name, true)
  name,version = name_and_version_from_string(new_resource.name)
  if status[:installed] && (version.nil? || version == status[:version] )
      Chef::Log.info("#{status[:name]} #{status[:version]} already installed: skip install")
  else
    cmd  = "npm -g install #{new_resource.name}"
    cmd += "@#{new_resource.version}" if new_resource.version
    execute "install NPM package #{new_resource.name}" do
      command cmd
    end
  end
end

action :install_local do
  path = new_resource.path if new_resource.path
  cmd  = "npm install #{new_resource.name}"
  cmd += "@#{new_resource.version}" if new_resource.version
  execute "install NPM package #{new_resource.name} into #{path}" do
    cwd path
    command cmd
  end
end

action :uninstall do
  cmd  = "npm -g uninstall #{new_resource.name}"
  cmd += "@#{new_resource.version}" if new_resource.version
  execute "uninstall NPM package #{new_resource.name}" do
    command cmd
  end
end

action :uninstall_local do
  path = new_resource.path if new_resource.path
  cmd  = "npm uninstall #{new_resource.name}"
  cmd += "@#{new_resource.version}" if new_resource.version
  execute "uninstall NPM package #{new_resource.name} from #{path}" do
    cwd path
    command cmd
  end
end

private

def package_status(package, is_global)
  info = `npm #{is_global ? "-g" : ""} ls -p  -l cube`.chop
  ret_hash = {}
  ret_hash[:installed] = info.empty? ? false : true
  return ret_hash if !ret_hash[:installed]
  name_and_version = name_and_version_from_string( info.split('/').last.split(':').last )
  ret_hash[:name] = name_and_version[0]
  ret_hash[:version] = name_and_version[1]
  ret_hash
end

def name_and_version_from_string(package_string)
  return package_string.split('@')
end
