package client

import (
	"context"
	"errors"
	"log"
	"os"
	"strings"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/appcheck"
	"google.golang.org/api/option"
)

// NewAppCheckClient creates the shared Firebase App Check client. Call it
// once at startup. It reads the Firebase project ID from the
// FIREBASE_PROJECT_ID env var.
//
// The client verifies tokens locally against Firebase's public keys, which
// it downloads at startup and refreshes every 6 hours, so no Google Cloud
// credentials are needed.
func NewAppCheckClient(ctx context.Context) (*appcheck.Client, error) {
	// TrimSpace guards against stray spaces or newlines picked up when the
	// value is copied and pasted. Even one would make every token fail the
	// audience check.
	projectID := strings.TrimSpace(os.Getenv("FIREBASE_PROJECT_ID"))
	if projectID == "" {
		return nil, errors.New("FIREBASE_PROJECT_ID is not set")
	}
	// %q prints the value in quotes with escapes, so hidden characters show.
	log.Printf("app check: verifying tokens for Firebase project %q", projectID)

	app, err := firebase.NewApp(ctx,
		&firebase.Config{ProjectID: projectID},
		// Only VerifyOneTimeToken (replay protection) calls Google APIs and
		// needs credentials. We use VerifyToken, which doesn't.
		option.WithoutAuthentication(),
	)
	if err != nil {
		return nil, err
	}

	return app.AppCheck(ctx)
}
