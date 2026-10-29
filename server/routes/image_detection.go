package routes

import (
	"context"
	"drummit/app/client"
	_ "embed"
	"encoding/base64"
	"encoding/json"
	"log"
	"time"

	"net/http"
	"strings"

	"google.golang.org/genai"
	"google.golang.org/genai/interactions/models/interactions"
	"google.golang.org/genai/interactions/models/operations"
)

// geminiTimeout caps how long one detection request may wait on Gemini.
const geminiTimeout = 120 * time.Second

// DetectionHandler handles POST /detection. It holds the shared Gemini
// client so every request reuses one client instead of building a new one.
type DetectionHandler struct {
	Gemini *genai.Client
}

func (h *DetectionHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	imageData, uploadErr := client.ReadUploadedImage(w, r, "image")
	if uploadErr != nil {
		log.Printf("upload error: %v", uploadErr)
		client.JsonError(w, uploadErr.Error(), http.StatusBadRequest)
		return
	}

	base64Image := base64.StdEncoding.EncodeToString(imageData.Data)

	// Tie the Gemini call to the request: it stops if the client disconnects,
	// and gives up after geminiTimeout either way.
	ctx, cancel := context.WithTimeout(r.Context(), geminiTimeout)
	defer cancel()

	format := interactions.NewCreateModelInteractionResponseFormat(
		interactions.NewResponseFormat(interactions.TextResponseFormat{
			MimeType: interactions.TextResponseFormatMimeTypeApplicationJSON.ToPointer(),
			Schema:   scanResultSchema,
		}),
	)

	start := time.Now()
	genaiRes, genaiErr := h.Gemini.Interactions.Create(ctx, operations.CreateInteractionRequest{
		Body: operations.NewCreateInteractionRequestBody(interactions.CreateModelInteraction{
			Model: interactions.Model("gemini-3.8-flash"),
			Input: new(interactions.NewInteractionsInput([]interactions.Content{
				interactions.NewContent(interactions.TextContent{
					Text: detectionPromptText,
				}),
				interactions.NewContent(interactions.ImageContent{
					Data:     new(base64Image),
					MimeType: new(interactions.ImageContentMimeType(imageData.MIMEType)),
				}),
			})),
			ResponseFormat: new(format),
			GenerationConfig: new(interactions.GenerationConfig{
				ThinkingLevel: interactions.ThinkingLevelMedium.ToPointer(),
			}),
		}),
	})
	log.Printf("gemini call took %s", time.Since(start).Round(time.Millisecond))

	if genaiErr != nil {
		log.Printf("gemini error: %v", genaiErr)
		if ctx.Err() == context.DeadlineExceeded {
			client.JsonError(w, "image detection timed out", http.StatusGatewayTimeout)
			return
		}
		client.JsonError(w, genaiErr.Error(), http.StatusInternalServerError)
		return
	}

	output := getOutputText(genaiRes.Interaction)

	var result ScanResponse
	if err := json.Unmarshal([]byte(output), &result); err != nil {
		log.Printf("model returned invalid JSON: %v\n%s", err, output)
		client.JsonError(w, "invalid response from model", http.StatusBadGateway)
		return
	}

	result.DateScanned = time.Now().UTC().Truncate(time.Second)
	if result.Items == nil {
		result.Items = []ScanResponseItem{}
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(result); err != nil {
		log.Printf("encoding response: %v", err)
	}
}

func getOutputText(i *interactions.Interaction) string {
	if t := i.GetOutputText(); t != nil {
		return *t
	}

	var text strings.Builder
	for _, step := range i.Steps {
		if step.ModelOutputStep == nil {
			continue
		}
		for _, c := range step.ModelOutputStep.GetContent() {
			if c.TextContent != nil {
				text.WriteString(c.TextContent.GetText())
				break
			}
		}
	}
	return text.String()
}

//go:embed image_detection_prompt.txt
var detectionPromptText string

var itemSchema map[string]any = map[string]any{
	"type": "object",
	"required": []string{
		"type",
		"subtype",
		"brand",
		"model",
		"diameter",
		"depth",
		"confidence_level",
		"confidence_explanation",
		"improvement_suggestions",
		"box_2d",
	},
	"properties": map[string]any{
		"type": map[string]any{
			"type":        "string",
			"enum":        []string{"drum", "cymbal", "pedal", "stick", "other"},
			"description": "This property is for the broad drum-related category the item falls under",
		},
		"subtype": map[string]any{
			"type": []string{"string", "null"},
			"enum": []string{
				"drum_snare",
				"drum_tom",
				"drum_bass",
				"cymbal_crash",
				"cymbal_splash",
				"cymbal_ride",
				"cymbal_hihat",
				"cymbal_china",
				"cymbal_fx",
				"stick_wood",
				"stick_nylon",
			},
			"description": "This property is a more specific item that falls under the 'type' property. Each 'subtype' enum is prefixed with a 'type' enum. The 'subtype' enum prefix should always match the 'type' value. Use null if a 'subtype' cannot be determined or is not applicable.",
		},
		"brand": map[string]any{
			"type":        []string{"string", "null"},
			"description": "Brand name, or null if it cannot be determined",
		},
		"model": map[string]any{
			"type":        []string{"string", "null"},
			"description": "Model line or series. Or null if it cannot be determined",
		},
		"diameter": map[string]any{
			"type":        []string{"integer", "null"},
			"description": "Estimated diameter in inches. This property only applies to cymbal and drum types. Use null if the size cannot be determined or for types other than cymbal and drum",
		},
		"depth": map[string]any{
			"type":        []string{"integer", "null"},
			"description": "Similar to 'diameter'. Estimated depth in inches. This property only applies to the drum type. If the item is a different type or the depth cannot be determined, use null",
		},
		"confidence_level": map[string]any{
			"type":        "string",
			"enum":        []string{"low", "medium", "high"},
			"description": "Confidence level that this item was detected accurately",
		},
		"confidence_explanation": map[string]any{
			"type":        "string",
			"description": "A brief explanation of why the confidence_level is what it is and what aspects of the image determined it.",
		},
		"improvement_suggestions": map[string]any{
			"type":        "array",
			"items":       map[string]any{"type": "string"},
			"description": "A list of brief suggestions to make detecting the item more accurate. Use empty array if there are no suggestions.",
		},
		"box_2d": map[string]any{
			"type":        "array",
			"items":       map[string]any{"type": "integer"},
			"description": "The 2D bounding box of the item as [ymin, xmin, ymax, xmax] normalized to 0-1000.",
		},
	},
}

var scanResultSchema map[string]any = map[string]any{
	"type": "object",
	"properties": map[string]any{
		"title": map[string]any{
			"type":        "string",
			"description": "A brief title describing the image (i.e. 'Rehearsal Room Drum Kit').",
		},
		"items": map[string]any{
			"type":  "array",
			"items": itemSchema,
		},
	},
	"required": []string{"title", "items"},
}

type ScanResponse struct {
	Title       string             `json:"title"`
	DateScanned time.Time          `json:"date_scanned"`
	Items       []ScanResponseItem `json:"items"`
}

type ScanResponseItem struct {
	Type                   string   `json:"type"`
	Box2D                  []int    `json:"box_2d"`
	ImprovementSuggestions []string `json:"improvement_suggestions"`
	ConfidenceLevel        string   `json:"confidence_level"`
	ConfidenceExplanation  string   `json:"confidence_explanation,omitempty"`
	Subtype                *string  `json:"subtype,omitempty"`
	Brand                  *string  `json:"brand,omitempty"`
	Model                  *string  `json:"model,omitempty"`
	Diameter               *int     `json:"diameter,omitempty"`
	Depth                  *int     `json:"depth,omitempty"`
}
