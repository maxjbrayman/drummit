package client

import (
	"bytes"
	"image"
	"image/gif"
	"image/jpeg"
	"image/png"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"testing"
)

// uploadRequest builds a multipart request like the iOS app sends, with
// data in the "image" field. The Content-Type is always claimed to be JPEG,
// to show the server checks the bytes, not the claim.
func uploadRequest(t *testing.T, data []byte) *http.Request {
	t.Helper()
	var body bytes.Buffer
	form := multipart.NewWriter(&body)
	part, err := form.CreateFormFile("image", "image.jpeg")
	if err != nil {
		t.Fatal(err)
	}
	part.Write(data)
	form.Close()

	r := httptest.NewRequest(http.MethodPost, "/detection", &body)
	r.Header.Set("Content-Type", form.FormDataContentType())
	return r
}

func encode(t *testing.T, enc func(*bytes.Buffer, image.Image) error) []byte {
	t.Helper()
	var buf bytes.Buffer
	if err := enc(&buf, image.NewRGBA(image.Rect(0, 0, 2, 2))); err != nil {
		t.Fatal(err)
	}
	return buf.Bytes()
}

func TestReadUploadedImageFormats(t *testing.T) {
	pngData := encode(t, func(b *bytes.Buffer, m image.Image) error { return png.Encode(b, m) })
	jpegData := encode(t, func(b *bytes.Buffer, m image.Image) error { return jpeg.Encode(b, m, nil) })
	gifData := encode(t, func(b *bytes.Buffer, m image.Image) error { return gif.Encode(b, m, nil) })
	// The start of a WebP file: Go identifies WebP from this header alone.
	webpData := []byte("RIFF\x00\x00\x00\x00WEBPVP8 ")

	tests := []struct {
		name     string
		data     []byte
		wantMIME string // empty means the upload should be rejected
	}{
		{"jpeg", jpegData, "image/jpeg"},
		{"png", pngData, "image/png"},
		{"webp", webpData, "image/webp"},
		{"gif is rejected", gifData, ""},
		{"text is rejected", []byte("definitely not an image"), ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			img, err := ReadUploadedImage(httptest.NewRecorder(), uploadRequest(t, tt.data), "image")
			if tt.wantMIME == "" {
				if err == nil {
					t.Fatalf("accepted %s upload, want rejection", img.MIMEType)
				}
				return
			}
			if err != nil {
				t.Fatalf("rejected upload: %v", err)
			}
			if img.MIMEType != tt.wantMIME {
				t.Errorf("MIME type %q, want %q", img.MIMEType, tt.wantMIME)
			}
		})
	}
}
