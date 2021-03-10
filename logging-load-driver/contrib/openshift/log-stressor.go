package main

import (
    "flag"
    "fmt"
    "log"
    "math/rand"
    "strings"
    "time"
)

func main() {

    var payloadGen string
    var distribution string
    var payloadSize int
    var messagesPerSecond int

    flag.StringVar(&payloadGen, "payload-gen", "fixed", "Payload generator [enum] (default = fixed)")
    flag.StringVar(&distribution, "distribution", "fixed", "Payload distribution [enum] (default = fixed)")
    flag.IntVar(&payloadSize, "payload_size", 10, "Payload length [int] (default = 10)")
    flag.IntVar(&messagesPerSecond, "msgpersec", 1, "Number of messages per second (default = 1)")

    flag.Parse()

    sequenceNumber := 0
    var rnd = rand.New( rand.NewSource(time.Now().UnixNano()))
    hash := fmt.Sprintf("%032X", rnd.Uint64())

    for {
        payload := strings.Repeat("*", payloadSize)
        log.Printf("goloader seq - %s - %010d - %s",hash, sequenceNumber, payload)
        sequenceNumber ++
        sleep := 1.0/ float64(messagesPerSecond)
        time.Sleep(time.Duration(sleep* float64(time.Second)))
    }
}