#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rbbt-util'
require 'rbbt/util/simpleopt'
require 'rbbt/util/cmd'

$0 = "rbbt #{$previous_commands*""} #{ File.basename(__FILE__) }" if $previous_commands

options = SOPT.setup <<EOF

Build a provision script

$ #{$0} [options]

-h--help Print this help
-u--user* System user to bootstrap
-w--workflow* Workflows to bootstrap
-s--server* Main Rbbt remote server (file-server and workflow server)
-fs--file_server* Rbbt remote file server
-ws--workflow_server* Rbbt remote workflow server
-rr--remote_resources* Remote resources to gather from file-server
-rw--remote_workflows* Remote workflows server from workflow-server
-ss--skip_base_system Skip base system installation
-sr--skip_ruby Skip ruby setup installation
-sb--skip_bootstrap Skip user bootstrap
-c--concurrent Prepare system for high-concurrency
-dt--docker* Build docker image using the provided name
-df--docker_file* Use a Dockerfile different than the default
-dd--docker_dependency* Use a different image in the Dockerfile FROM
EOF
if options[:help]
  if defined? rbbt_usage
    rbbt_usage and exit 0 
  else
    puts SOPT.doc
    exit
  end
end

USER = options[:user] || 'rbbt'
SKIP_BASE_SYSTEM = options[:skip_base_system]
SKIP_RUBY = options[:skip_ruby]
SKIP_BOOT = options[:skip_bootstrap]

VARIABLES={
 :RBBT_LOG => 0,
 :BOOTSTRAP_WORKFLOWS => (options[:workflow] || "Enrichment Translation Sequence MutationEnrichment").split(/[\s,]+/)*" "
}

VARIABLES[:RBBT_NO_LOCKFILE_ID] = "true" if options[:concurrent]
VARIABLES[:RBBT_SERVER] = options[:server] if options[:server]
VARIABLES[:RBBT_FILE_SERVER] = options[:file_server] if options[:file_server]
VARIABLES[:RBBT_WORKFLOW_SERVER] = options[:workflow_server] if options[:workflow_server]
VARIABLES[:REMOTE_RESOURCES] = options[:remote_resources].split(/[\s,]+/)*" " if options[:remote_resources]
VARIABLES[:REMOTE_WORKFLOWS] = options[:remote_workflows].split(/[\s,]+/)*" " if options[:remote_workflows]


provision_script =<<EOF
cat "$0"
echo "Running provisioning"
echo


# BASE SYSTEM
echo "1. Provisioning base system"
#{File.read("bin/ubuntu_setup.sh") unless SKIP_BASE_SYSTEM}

# BASE SYSTEM
echo "2. Setting up ruby"
#{File.read("bin/ruby_setup.sh") unless SKIP_RUBY}

#{"exit" if SKIP_BOOT}

####################
# USER CONFIGURATION

if [[ '#{ USER }' == 'root' ]] ; then
  home_dir='/root'
else
  useradd -ms /bin/bash #{USER}
  home_dir='/home/#{USER}'
fi

user_script=$home_dir/.rbbt/bin/provision
mkdir -p $(dirname $user_script)
chown -R #{USER} /home/#{USER}/.rbbt/
cat > $user_script <<'EUSER'

. /etc/profile

echo "2.1. Custom variables"
#{
  VARIABLES.collect do |variable,value|
    "export " << ([variable,'"' << value.to_s << '"'] * "=")
  end * "\n"
}

echo "2.2. Default variables"
#{ File.read("bin/variables.sh") }

echo "2.3. Configuring rbbt"
#{File.read("bin/user_setup.sh")}

echo "2.4. Bootstrap system"
#{File.read("bin/bootstrap.sh")}

EUSER
####################
echo "2. Running user configuration as '#{USER}'"
chown #{USER} $user_script;
su -l -c "bash $user_script" #{USER}

# DONE
echo
echo "Installation done."

#--------------------------------------------------------

EOF

docker_dependency = options[:docker_dependency]

if options[:docker]
  dockerfile = options[:dockerfile] || File.join(File.dirname(File.dirname(__FILE__)), 'Dockerfile')
  dockerfile_text = Open.read(dockerfile)
  dockerfile_text.sub!(/^FROM.*/,'FROM ' + docker_dependency) if docker_dependency
  TmpFile.with_file(nil, false) do |dir|
    FileUtils.mkdir_p dir
    Path.setup(dir)
    Open.write(dir["Dockerfile"].find, dockerfile_text)
    Open.write(dir['provision.sh'], provision_script)

    puts
    puts "provision.sh"
    puts "=========="
    puts provision_script

    puts
    puts "Dockerfile"
    puts "=========="
    puts dockerfile_text

    puts
    puts "RUN"
    puts "=========="
    puts "docker build -t #{options[:docker]} '#{dir}'"
    io = CMD.cmd("docker build -t #{options[:docker]} '#{dir}'", :pipe => true, :log => true)
    while line = io.gets
      puts line
    end
  end
else
  puts provision_script
end

