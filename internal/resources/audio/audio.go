// Package audio contains the audio files used in the game.
package audio

import _ "embed"

// Jab sound.
//
//go:embed jab.wav
var Jab []byte

// Jump sound.
//
//go:embed jump.ogg
var Jump []byte
