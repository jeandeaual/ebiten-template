package main

import (
	"github.com/hajimehoshi/ebiten/v2"

	"game/internal/game"
)

func main() {
	ebiten.SetWindowSize(game.ScreenWidth, game.ScreenHeight)
	ebiten.SetWindowTitle("Flappy Gopher (Ebitengine Demo)")

	if err := ebiten.RunGame(game.NewGame()); err != nil {
		panic(err)
	}
}
