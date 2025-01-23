package main

import (
	"fmt"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

func main() {
	// Comienza el programa overflow"
	o := Overflow(
		WithGlobalPrintOptions(),
	)
	fmt.Println("Testing Vzla Democracy DAO contract")
	//
	///// Probando CADENCE en Overflow /////
	//
	color.Red("Admin should be able to create the first Topic")
	o.Tx("admin/create_topic",
		WithSigner("account"),
		WithArg("title", "Next Region"),
		WithArg("description", "Vote on which of the following five regions should be added next. The top 2 will be selected!"),
		WithArg("minimumVotes", "20"),
		WithArg("options", `["Barinas", "Amazonas"]`),
	)
	color.Red("User should be able to setup their account for IP")
	o.Tx("influencePoint/setup_ip",
		WithSigner("bob"),
	)
	// Get IP balance
	color.Red("User should be able to check their IP balance")
	o.Script("influencePoint/get_balance",
		WithArg("address", "bob"),
	)
	// Vote
	color.Red("User should be able to submit a vote")
	o.Tx("vote",
		WithSigner("bob"),
		WithArg("option", "0"),
	)
	// Get votes and balance
	color.Red("User should be able to get total votes for all options")
	o.Script("get_votes")
	color.Red("User should be able to check their IP balance AGAIN")
	o.Script("get_balance",
		WithArg("account", "bob"),
	)
}
