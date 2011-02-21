include_recipe "homebrew"

directory node[:npm][:root] do
  owner node[:npm][:user]
  group "staff"
end

package "node"

template node[:npm][:globalconfig] do
  variables node[:npm]
  mode 0644
  owner node[:npm][:user]
  group "staff"
end

if File.exist?("#{node[:homebrew][:prefix]}/bin/npm")
  npm_package "npm" do
    action :upgrade
  end
else
  url    = "http://registry.npmjs.org/npm/latest"
  latest = JSON.parse(open(url).read)['dist']

  root    = Chef::Config[:file_cache_path]
  npm_tar = "#{root}/npm.tar.gz"
  npm_dir = "#{root}/npm-#{latest['shasum']}"

  remote_file npm_tar do
    source latest['tarball']
    checksum latest['shasum']
    action :create_if_missing
  end

  archive npm_tar do
    path npm_dir
    not_if { File.exist?(npm_dir) }
  end

  execute "make uninstall dev" do
    cwd "#{npm_dir}/package"
    user node[:npm][:user]
  end
end
