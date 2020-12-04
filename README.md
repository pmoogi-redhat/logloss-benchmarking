#### logloss-benchmarking
this repo contains simulation script for 
 1. replicating log-loss at different rate of logs generation (msg line per sec or no of bytes per sec)
 2. measuring log-loss at a given setting of log-size-max limits
 
 The loader and verifiy-loader scripts are taken from https://github.com/ViaQ/logging-load-driver
 They are further changed to have more debug/print statements for better understanding on log-loss
 Simulation script uses a custom conmon binary which is changed for setting a specific value of log-size-max 
 Above is done using hardcoded way as podman latest version doesn't support passing run time this value via configuration variable
