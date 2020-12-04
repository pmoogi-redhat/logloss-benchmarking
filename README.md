#### logloss-benchmarking
This repo contains simulation script for 
 1. replicating log-loss at different rate of logs generation (msg line per sec or no of bytes per sec)
 2. measuring log-loss at a given setting of log-size-max limits
 
 The loader and verifiy-loader scripts are taken from https://github.com/ViaQ/logging-load-driver
 They are further changed to have more debug/print statements for better understanding on log-loss
 Simulation script uses a custom conmon binary which is changed for setting a specific value of log-size-max 
 Above is done using hardcoded way as podman latest version doesn't support passing run time this value via configuration variable.
 
 Below Results are obtained on setting of MSGPERSEC=100 to 10000 log-lines per sec, pay-load size 1014 bytes, payload_gen method as fixed (not random) etc.
 

|msq-lines-per-sec log generation rate | Rate of writing to disk bytes per sec | Log-max-size limit set to.. | Loss rate(mb per sec) as we see.. |msg-len set to |
|--|--|--|--|--|
|100  | 100*1024=0.1mb| 1mb | 0.012| 1024 |
|--|--|--|--|--|
|1000 | 1000*1024=1mb | 1mb | 0.13 | 1024 |
|--|--|--|--|--|
|2000 | 2000*1024=2mb | 1mb | 0.24 | 1024 |
|--|--|--|--|--|
|3000 | 3000*1024=3mb | 1mb | 0.37 | 1024 |
|--|--|--|--|--|
|4000 | 4000*1024=4mb | 1mb | 0.50 | 1024 |
|--|--|--|--|--|
|5000 | 5000*1024=5mb | 1mb | 0.64 | 1024 |
|--|--|--|--|--|
|6000 | 6000*1024=6mb | 1mb | 0.75 | 1024 |
|--|--|--|--|--|
|7000 | 7000*1024=7mb | 1mb | 0.9  | 1024 |
|--|--|--|--|--|
|8000 | 8000*1024=8mb | 1mb | 1.04 | 1024 |
|--|--|--|--|--|
|9000 |9000*1024=9mb  | 1mb | 1.27 | 1024 |
|--|--|--|--|--|
|10000|10000*1024=10mb|1mb  | 1.3  | 1024 |
|--|--|--|--|--|
