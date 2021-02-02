

The below docs capture the steps to clone fluentd and other fluentd plugins, do customer build of a local gem file, and get that installed in your hostmachine
##prerequisites
 1. ensure you got ruby installed reference : https://www.ruby-lang.org/en/documentation/installation/
 $ sudo yum install ruby

##Steps
 1. git clone as git clone https://github.com/pmoogi-redhat/fluentd.git [assuming that you have forked the upstream fluentd into your own remote repo]
 2. Go to your repo 
    $ cd path/to/fluentd/
 3. Do 
   $gem build -V fluentd.gemspec
 4. Do gem install
   $gem install -V --local fluentd-1.12.0.gem 
   
 ## You may add changes in the plugins 
   $vi in_tail.rb
 The changed plugin files can be reflected in the installed directory by simplying copying the to the below default installed directories
   $cp /path/to/fluentd/lib/fluent/plugin/in_tail.rb /usr/local/share/gems/gems/fluentd-1.12.0/lib/fluent/plugin/.
 OR do a fresh gem build as step 4 and that followed by step 5 for new installation. Step 5 actually copies plugin .rb files to /usr/local/share/gems/gems/fluentd-1.12.0/lib/fluent/plugin/. directory
   
   Similarly other plugins can be changed and installed by hacking the above step
   
 ## You may run fluentd process in your hostmachine by the following step
 6. Run fluentd in the local host machine with the above plugin code changes reflected by running the below
    $sudo fluentd -c fluent-test-tail.conf


## As another option for installing fluentd from source usnig bundle utility is given here https://docs.fluentd.org/installation/install-from-source
