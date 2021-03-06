
### Installing custom fluentd

The below captures the steps to clone fluentd and other fluentd plugins, do custom build of a local gem file, and get that installed in your hostmachine

> note: as pre-req you need ruby version 2.7 installed (e.g. instructions for [centos](https://tecadmin.net/install-ruby-latest-stable-centos/))  

####Follow the steps as the below
 
 1. git clone  
    `git clone https://github.com/pmoogi-redhat/fluentd.git`    
 > note: assuming you have forked the upstream fluentd into your own remote repo
 2. Go to your repo  
    `cd fluentd`
 3. Execute gem build    
     `gem build -V fluentd.gemspec`  
 4. Execute bundler  
    `bundler install`   
    > note: ass needed execute `gem install bundler:2.2.7` to update version of bundler    

 5. Execute gem install  
    `sudo gem install -V -l fluentd-1.12.0.gem`   
    > note: installing fluentd with root permission helps it to read logfiles generated by container as those files are written with 'root' user and cgroup
    
 ### How to customize fluentd or plugins 
   For example change tail code:  
   `vi in_tail.rb`    
   
   The changed plugin files can be reflected in the installed directory by copying update file into the below default installed directories  
   `cp /path/to/fluentd/lib/fluent/plugin/in_tail.rb /usr/local/share/gems/gems/fluentd-1.12.0/lib/fluent/plugin/.`
   OR do a fresh gem build as described from step 3 to create a new installation  
    
    > note: Step 5 actually copies plugin .rb files into `/usr/local/share/gems/gems/fluentd-1.12.0/lib/fluent/plugin/.` directory  
   
   Similarly, other plugins can be changed and installed by hacking the above step
   
 ### How to run fluentd on your local machine
  To execute fluentd on your local machine with the plugins and code changes, execute:  
     
  `fluentd -c fluent.conf`  
    
 > note : As another option for installing fluentd from source usnig bundle utility is given here https://docs.fluentd.org/installation/install-from-source


### installing fluent-prometheus-plugin & adding new metric to its prometheus_tail_monitor plugin

####Follow the steps as the below

     $git clone https://github.com/pmoogi-redhat/fluent-plugin-prometheus.git
     
     $vi lib/fluent/plugin/in_prometheus_tail_monitor.rb, make changes to reflect new metric
     
     $git add lib/fluent/plugin/in_prometheus_tail_monitor.rb and do git commit -m "added new metric as a trial implementation"
     
     $gem build -V fluent-plugin-prometheus.gemspec in your local repo
 
     Before you do gem install on <gem-generated-from-previous step> do
     $gem install prometheus-client -v 0.9.0
 
     Install the fluent-plugin-prometheus plugin
     $sudo gem install -V  fluent-plugin-prometheus-1.8.5.gem
    
     > note: The above step copies your changes done in the lib/fluent/plugin/in_prometheus_tail_monitor.rb to /usr/local/share/gems/gems/fluent-plugin-prometheus-1.8.5/lib/fluent/plugin/.  so you can hack this by directly copying your changes to this intalled location of plugin
