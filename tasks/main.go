package main

import (
	"fmt"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

func main() {
	// Comienza el programa overflow
	o := Overflow(
		WithGlobalPrintOptions(),
	)
	fmt.Println("Testing Vzla Democracy cadence contracts")
	//
	///// Probando CADENCE en Overflow /////
	//
	color.Red("Admin should be able to upload metadata to the contract")
	// upload_metadata
	o.Tx("admin/upload_metadata",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
	color.Red("Admin should be able to create a set")
	// Incrementa el contador
	o.Tx("admin/create_set",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
	color.Red("Admin should be able to add cards to a set")
	// create_season
	o.Tx("admin/add_card_to_set",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
	color.Red("Admin should be able to starts a new season with selected sets")
	// create_season
	o.Tx("admin/start_new_season",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
}
