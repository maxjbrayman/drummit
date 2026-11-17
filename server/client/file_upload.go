package client

import (
	"errors"
	"io"
	"net/http"
)

// allowedImageTypes are the formats both Gemini accepts and Go's
// http.DetectContentType can recognise. Anything else (GIF, BMP, ICO...) is
// rejected here, before it costs a Gemini call.
var allowedImageTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/webp": true,
}

type Image struct {
	Data     []byte
	MIMEType string
	Filename string
}

func ReadUploadedImage(w http.ResponseWriter, r *http.Request, field string) (*Image, error) {
	r.Body = http.MaxBytesReader(w, r.Body, 10<<20)
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		if _, tooBig := errors.AsType[*http.MaxBytesError](err); tooBig {
			return nil, errors.New("File too large")
		}
		return nil, errors.New("Invalid form data")
	}

	file, handler, err := r.FormFile(field)
	if err != nil {
		return nil, errors.New("Missing or invalid image upload")
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		return nil, errors.New("could not read upload")
	}

	// Check the bytes themselves, not the file name or the Content-Type the
	// client claims, since either can be faked.
	mime := http.DetectContentType(data)
	if !allowedImageTypes[mime] {
		return nil, errors.New("image must be a JPEG, PNG or WebP")
	}

	return &Image{
		Data:     data,
		MIMEType: mime,
		Filename: handler.Filename,
	}, nil
}
