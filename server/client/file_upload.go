package client

import (
	"errors"
	"io"
	"net/http"
	"strings"
)

type Image struct {
    Data []byte
    MIMEType string
    Filename string
}

func ReadUploadedImage(w http.ResponseWriter, r *http.Request, field string) (*Image, error) {
    r.Body = http.MaxBytesReader(w, r.Body, 10<<20)
    if err := r.ParseMultipartForm(10 << 20); err != nil {
    var tooBig *http.MaxBytesError
        if errors.As(err, &tooBig) {
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

    mime := http.DetectContentType(data)
    if !strings.HasPrefix(mime, "image/") {
        return nil, errors.New("file must be an image")
    }

    return &Image{
        Data: data,
        MIMEType: mime,
        Filename: handler.Filename,
    }, nil
}