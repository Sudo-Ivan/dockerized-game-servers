package main

import (
	"log"

	"gameserverpanel/internal/runtime"
)

func main() {
	if err := runtime.Run(); err != nil {
		log.Fatal(err)
	}
}
