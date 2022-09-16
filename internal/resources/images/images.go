// Package images contains the images used in the game.
package images

import _ "embed"

// Gopher image.
//
//go:embed gopher.png
var Gopher []byte

// Tiles image.
//
//go:embed tiles.png
var Tiles []byte
