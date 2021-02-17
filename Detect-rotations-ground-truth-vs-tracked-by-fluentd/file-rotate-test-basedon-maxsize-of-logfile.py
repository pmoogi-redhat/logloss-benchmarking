import logging
import logging.handlers
import time
import sys

def payload_fixed(size):
    return 'x' * size

def main():

    #just to limit upper bound to log lines generation to 10 million lines
    MAXLOGLINES=10000000
    maxsize=int(sys.argv[1])
    rateofloglineG=float(sys.argv[2])
    logfilename=sys.argv[3]

    print("maxsize of log file",maxsize)
    print("gap between two log lines",rateofloglineG)

    log = logging.getLogger(__name__)
    fsize=1024
    payloadfixedsize=payload_fixed(fsize)
    #class logging.handlers.RotatingFileHandler(filename, mode='a', maxBytes=0, backupCount=0, encoding=None, delay=False, errors=None)
    log_formatter = logging.Formatter('[%(asctime)s][%(levelname)s](%(threadName)-10s) %(message)s')
    trfh = logging.handlers.RotatingFileHandler(logfilename, mode='a', encoding='utf-8', maxBytes=maxsize, backupCount=100,delay=False)
    trfh.setFormatter(log_formatter)
    log.addHandler(trfh)
    count=0
    while count < MAXLOGLINES :
        time.sleep(rateofloglineG)
        count=count+1
        log.warning(payloadfixedsize + ':' + str(count))
    return

main()
