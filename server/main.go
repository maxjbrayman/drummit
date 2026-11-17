package main

import (
	"errors"
	"io/fs"
	"log"

	"github.com/joho/godotenv"
)

func main() {
	// Load variables from a .env file in the working directory, for local
	// development. Variables that are already set always win, so a host's
	// settings, or one you set in the terminal for a single run, are never
	// overridden. In production there's no .env file and the host provides
	// everything, so a missing file is fine.
	if err := godotenv.Load(); err != nil && !errors.Is(err, fs.ErrNotExist) {
		log.Fatalf("loading .env: %v", err)
	}

	initializeHttpServer()
}
