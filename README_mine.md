########################
### NEW installation ###
########################
# http://misheska.com/blog/2014/11/25/chef-server-12/

yum localinstall chef-server-core-12.1.2-1.el7.x86_64.rpm
chef-server-ctl reconfigure

# Create an admin user
mkdir /vagrant/.chef
cd /vagrant/.chef
chef-server-ctl user-create iliyahoo Iliya Strakovich iliya@strakovich.com wearetv1 --filename iliyahoo.pem

# Create an organization
chef-server-ctl org-create customizingchef "Customizing Chef" --association iliyahoo --filename customizingchef-validator.pem

# Create knife.rb file
cat << EOF > ../.chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "iliyahoo"
client_key               "#{current_dir}/iliyahoo.pem"
validation_client_name   "customizingchef-validator"
validation_key           "#{current_dir}/customizingchef-validator.pem"
chef_server_url          "https://chef-server/organizations/customizingchef"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
EOF

# install web UI
chef-server-ctl install opscode-manage
opscode-manage-ctl reconfigure
chef-server-ctl reconfigure

# on workstation
# go to vagrant shared folder
cd ../
knife ssl fetch
knife ssl check
knife client list

# bootstrap new node
knife bootstrap --sudo --ssh-user vagrant --ssh-password vagrant --no-host-key-verify chef-node01

# download cookbooks
cd cookbooks
knife cookbook site download chef-client

# unpack and remove archives
for i in $(ls *.tar.gz) ; do tar -zxvf $i ; rm -f $i ; done

# upload cookbooks on to chef-server
cd ../
knife cookbook upload chef-client --cookbook-path cookbooks

# instead of 'knife cookbook upload' use BERKS
# it resolves all dependencies
berks init <existed_cookbook>
# Getting a berks init error?
# If you get an error like [...] does not appear to be a valid cookbook. Does it have a metadata.rb?—upgrade your knife version.
# If you can’t, one workaround is just to add a metadata.rb file, the contents of which is simply name "packageshortnamehere":
cat << EOF > <existed_cookbook>/metadata.rb
name "packageshortnamehere"
maintainer 'Awesome Company, Inc.'
maintainer_email 'you@example.com'
EOF
# Then run berks init again.
berks instal -b <existed_cookbook>/Berksfile
berks upload git -b <existed_cookbook>/Berksfile --no-ssl-verify

# assign a recipe to node
knife node run_list add chef-node01 "recipe[chef-client::delete_validation]"
knife node run_list add chef-node01 "recipe[chef-client]"

# set chef-node attributes:
{"chef_client":{"config":{"ssl_verify_mode":":verify_peer","ssl_ca_file":"/chef-repo/.chef/trusted_certs/chef-server.crt"}}}

# launch assignment recipe on chef-node
chef-client

