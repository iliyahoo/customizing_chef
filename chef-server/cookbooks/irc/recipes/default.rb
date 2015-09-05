user 'tdi' do
      action :create
      comment "Test Driven Infrastructure"
      home "/home/tdi"
      manage_home true
end
    package 'irssi' do
      action :install
end
directory '/home/tdi/.irssi' do
      owner 'tdi'
      group 'tdi'
end
cookbook_file '/home/tdi/.irssi/config' do
      source 'irssi-config'
      owner 'tdi'
      group 'tdi'
end
