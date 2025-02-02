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
	// Get list of topics
	o.Script("dao/get_topics")
	// Setup bob with IP
	color.Red("Bob should be able to setup their account for IP")
	o.Tx("influencePoint/setup_ip",
		WithSigner("bob"),
	)
	// Get IP balance
	color.Red("Bob should be able to check their IP balance")
	o.Script("influencePoint/get_balance",
		WithArg("address", "bob"),
	)
	// Vote
	color.Red("Bob should be able to submit a vote")
	o.Tx("dao/vote",
		WithSigner("bob"),
		WithArg("topicID", "1"),
		WithArg("option", "Barinas"),
	)
	// Get votes
	color.Red("User should be able to get total votes for all options")
	o.Script("dao/get_votes",
		WithArg("topicID", "1"),
	)
	// Get IP balance on Bob
	color.Red("Bob's IP balance should have increased")
	o.Script("influencePoint/get_balance",
		WithArg("address", "bob"),
	)
	// Account votes and her account gets
	// setup for IP in the same transaction
	color.Red("Account will vote now")
	o.Tx("dao/vote_setup",
		WithSigner("account"),
		WithArg("topicID", "1"),
		WithArg("option", "Barinas"),
	)
	// Check IP balance for Account
	o.Script("influencePoint/get_balance",
		WithArg("address", "account"),
	)
	// Alice will also vote to reach minimum voters
	color.Red("Alice will vote now")
	o.Tx("dao/vote_setup",
		WithSigner("alice"),
		WithArg("topicID", "1"),
		WithArg("option", "Amazonas"),
	)
	// Check IP balance for Account
	o.Script("influencePoint/get_balance",
		WithArg("address", "alice"),
	)

}
