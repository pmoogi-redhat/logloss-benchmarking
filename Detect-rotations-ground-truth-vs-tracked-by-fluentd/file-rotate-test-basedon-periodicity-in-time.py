import logging
import logging.handlers
import time
import sys




def payload_fixed(size):
    return 'x' * size


def main():

    #one way to set upper bound to generate logs
    MAXLOGLINES=1000000

    interval=int(sys.argv[1])
    rateofloglinesG=float(sys.argv[2])
    logfilename=sys.argv[3]

    print("interval at which log rotation set",interval)
    print("interval between two loglines",rateofloglinesG)

    log = logging.getLogger(__name__)
    fsize=1024
    payloadfixedsize=payload_fixed(fsize)
    trfh = logging.handlers.TimedRotatingFileHandler(logfilename,
        encoding='utf-8', when='S', interval=interval, backupCount=100)
    trfh.setFormatter(logging.Formatter('%(asctime)s %(message)s'))
    log.addHandler(trfh)
    count=0
    while count < MAXLOGLINES :
        time.sleep(rateofloglinesG)
        count=count+1
        log.warning(payloadfixedsize + ':' + str(count))
    return

main()
