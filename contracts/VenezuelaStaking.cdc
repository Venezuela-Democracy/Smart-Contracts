/*
    VenezuelaStaking

    The VenezuelaIP Staking contract manages stakers' information.
    Forked from FlowIDTableStaking contract.
 */

import "FungibleToken"
import VenezuelaIP from "./InfluencePoint.cdc"


access(all)
contract VenezuelaStaking {
    // An entitlement for Staker access
    access(all) entitlement StakerEntitlement
    // An entitlement for Admin access
    access(all) entitlement AdminEntitlement
    /****** Staking Events ******/
    access(all)
    event NewEpoch(epoch: UInt64, totalStaked: UFix64, totalRewardPayout: UFix64)
    
    /// Staker Events
    access(all)
    event NewStakerCreated(stakerID: UInt64, amountCommitted: UFix64)
    
    access(all)
    event TokensCommitted(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event TokensStaked(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event TokensUnstaking(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event TokensUnstaked(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event NodeRemovedAndRefunded(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event RewardsPaid(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event MoveToken(stakerID: UInt64)
    
    access(all)
    event UnstakedTokensWithdrawn(stakerID: UInt64, amount: UFix64)
    
    access(all)
    event RewardTokensWithdrawn(stakerID: UInt64, amount: UFix64)
    
    /// Contract Field Change Events
    access(all)
    event NewWeeklyPayout(newPayout: UFix64)

    /// Contract Field Change Events
    access(all)
    event AdminCreated()
    
    /// Holds the identity table for all the stakers in the network.
    /// Includes stakers that aren't actively participating
    /// key = staker ID (also corresponds to VenezuelaPass ID)
    /// value = the record of that staker's info, tokens, and delegators
    access(contract)
    var stakers: @{UInt64: StakerRecord}
    
    /// The total amount of tokens that are staked for all the stakers
    access(contract)
    var totalTokensStaked: UFix64
    
    /// The total amount of tokens that are paid as rewards every epoch
    /// could be manually changed by the admin resource
    access(contract)
    var epochTokenPayout: UFix64
    
    /// Indicates if the staking auction is currently enabled
    access(contract)
    var stakingEnabled: Bool
    
    /// Paths for storing staking resources
    access(all)
    let StakingAdminStoragePath: StoragePath
    
    /*********** Staking Composite Type Definitions *************/
    /// Contains information that is specific to a staker
    access(all)
    resource StakerRecord {
        
        /// The unique ID of the staker
        /// Corresponds to the VenezuelaPass NFT ID
        access(all)
        let id: UInt64
        
        /// The total tokens that only this staker currently has staked
        access(all)
        var tokensStaked: @VenezuelaIP.Vault
        
        /// The tokens that this staker has committed to stake for the next epoch.
        access(all)
        var tokensCommitted: @VenezuelaIP.Vault
        
        /// Tokens that this staker is able to withdraw whenever they want
        access(all)
        var tokensUnstaked: @VenezuelaIP.Vault
        
        /// Staking rewards are paid to this bucket
        /// Can be withdrawn whenever
        access(all)
        var tokensRewarded:  @VenezuelaIP.Vault
        
        /// The amount of tokens that this staker has requested to unstake for the next epoch
        access(all)
        var tokensRequestedToUnstake: UFix64
        
        init(id: UInt64) {
            pre {
                VenezuelaStaking.stakers[id] == nil: "The ID cannot already exist in the record"
            }
            self.id = id
            self.tokensCommitted <- VenezuelaIP.createEmptyVault(vaultType: Type<@VenezuelaIP.Vault>())
            self.tokensStaked <- VenezuelaIP.createEmptyVault(vaultType: Type<@VenezuelaIP.Vault>())
            self.tokensUnstaked <- VenezuelaIP.createEmptyVault(vaultType: Type<@VenezuelaIP.Vault>())
            self.tokensRewarded <- VenezuelaIP.createEmptyVault(vaultType: Type<@VenezuelaIP.Vault>())
            self.tokensRequestedToUnstake = 0.0
            emit NewStakerCreated(stakerID: self.id, amountCommitted: self.tokensCommitted.balance)
        }

        /// Utility Function that checks a staker's overall committed balance from its borrowed record
        access(contract)
        fun stakerFullCommittedBalance(): UFix64 {
            if (self.tokensCommitted.balance + self.tokensStaked.balance) < self.tokensRequestedToUnstake {
                return 0.0
            } else {
                return self.tokensCommitted.balance + self.tokensStaked.balance - self.tokensRequestedToUnstake
            }
        }

        /// setter for tokensRequestedToUnstake
        access(contract)
        fun setTokensRequestedToUnstake(_ amount: UFix64){
            self.tokensRequestedToUnstake = amount
        }

        /// Utility Function that auth tokensStaked withdraw
        access(contract)
        fun authTokensStakedWithdraw(): auth(FungibleToken.Withdraw) &VenezuelaIP.Vault{
            return &self.tokensStaked
        }

        /// Utility Function that auth tokensCommitted withdraw
        access(contract)
        fun authTokensCommittedWithdraw(): auth(FungibleToken.Withdraw) &VenezuelaIP.Vault{
            return &self.tokensCommitted
        }

        /// Utility Function that auth tokensUnstaked withdraw
        access(contract)
        fun authTokensUnstakedWithdraw(): auth(FungibleToken.Withdraw) &VenezuelaIP.Vault{
            return &self.tokensUnstaked
        }

        /// Utility Function that auth tokensRewarded withdraw
        access(contract)
        fun authTokensRewardedWithdraw(): auth(FungibleToken.Withdraw) &VenezuelaIP.Vault{
            return &self.tokensRewarded
        }

    }

    /// Struct to create to get read-only info about a staker
    access(all)
    struct StakerInfo {
        access(all)
        let id: UInt64
        
        access(all)
        let tokensStaked: UFix64
        
        access(all)
        let tokensCommitted: UFix64
        
        access(all)
        let tokensUnstaked: UFix64
        
        access(all)
        let tokensRewarded: UFix64
        
        access(all)
        let tokensRequestedToUnstake: UFix64
        
        view init(stakerID: UInt64) {
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(stakerID)

            self.id = stakerRecord.id
            self.tokensStaked = stakerRecord.tokensStaked.balance
            self.tokensCommitted = stakerRecord.tokensCommitted.balance
            self.tokensUnstaked = stakerRecord.tokensUnstaked.balance
            self.tokensRewarded = stakerRecord.tokensRewarded.balance
            self.tokensRequestedToUnstake = stakerRecord.tokensRequestedToUnstake
        }
        
        access(all)
        view fun totalTokensInRecord(): UFix64 {
            return self.tokensStaked + self.tokensCommitted + self.tokensUnstaked + self.tokensRewarded
        }
    }
    
    access(all)
    resource interface StakerPublic {
        access(all)
        let id: UInt64
    }
    
    /// Resource that the staker operator controls for staking
    access(all)
    resource Staker: StakerPublic {
        
        /// Unique ID for the staker operator
        access(all)
        let id: UInt64

        init(id: UInt64) {
            self.id = id
        }

        /// Add new tokens to the system to stake during the next epoch
        access(StakerEntitlement)
        fun stakeNewTokens(_ tokens: @{FungibleToken.Vault}) {
            pre {
                VenezuelaStaking.stakingEnabled: "Cannot stake if the staking auction isn't in progress"
            }

            // Borrow the staker's record from the staking contract
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)
            emit TokensCommitted(stakerID: stakerRecord.id, amount: tokens.balance)

            // Add the new tokens to tokens committed
            stakerRecord.tokensCommitted.deposit(from: <-tokens)
        }

        /// Stake tokens that are in the tokensUnstaked bucket
        access(StakerEntitlement)
        fun stakeUnstakedTokens(amount: UFix64) {
            pre {
                VenezuelaStaking.stakingEnabled: "Cannot stake if the staking auction isn't in progress"
            }
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)
            var remainingAmount = amount

            // If there are any tokens that have been requested to unstake for the current epoch,
            // cancel those first before staking new unstaked tokens
            if remainingAmount <= stakerRecord.tokensRequestedToUnstake  {
                stakerRecord.setTokensRequestedToUnstake(stakerRecord.tokensRequestedToUnstake - remainingAmount)
                remainingAmount = 0.0
            } else if remainingAmount > stakerRecord.tokensRequestedToUnstake  {
                remainingAmount = remainingAmount - stakerRecord.tokensRequestedToUnstake
                stakerRecord.setTokensRequestedToUnstake(0.0)
            }

            // Commit the remaining amount from the tokens unstaked bucket
            stakerRecord.tokensCommitted.deposit(from: <- stakerRecord.authTokensUnstakedWithdraw().withdraw(amount: remainingAmount))
            emit TokensCommitted(stakerID: stakerRecord.id, amount: remainingAmount)
        }
        
        /// Stake tokens that are in the tokensRewarded bucket
        access(StakerEntitlement)
        fun stakeRewardedTokens(amount: UFix64) {
            pre {
                VenezuelaStaking.stakingEnabled: "Cannot stake if the staking auction isn't in progress"
            }

            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)
            stakerRecord.tokensCommitted.deposit(from: <- stakerRecord.authTokensRewardedWithdraw().withdraw(amount: amount))
            emit TokensCommitted(stakerID: stakerRecord.id, amount: amount)
        }

        /// Request amount tokens to be removed from staking at the end of the next epoch
        access(StakerEntitlement)
        fun requestUnstaking(amount: UFix64) {
            pre {
                VenezuelaStaking.stakingEnabled: "Cannot unstake if the staking auction isn't in progress"
            }
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)

            // If the request is greater than the total number of tokens
            // that can be unstaked, revert
            assert (
                stakerRecord.tokensStaked.balance +
                stakerRecord.tokensCommitted.balance
                >= amount + stakerRecord.tokensRequestedToUnstake,
                message: "Not enough tokens to unstake!"
            )

            // Get the balance of the tokens that are currently committed
            let amountCommitted = stakerRecord.tokensCommitted.balance

            // If the request can come from committed, withdraw from committed to unstaked
            if amountCommitted >= amount {

                // withdraw the requested tokens from committed since they have not been staked yet
                stakerRecord.tokensUnstaked.deposit(from: <-stakerRecord.authTokensCommittedWithdraw().withdraw(amount: amount))
            } else {
                let amountCommitted = stakerRecord.tokensCommitted.balance

                // withdraw the requested tokens from committed since they have not been staked yet
                stakerRecord.tokensUnstaked.deposit(from: <-stakerRecord.authTokensCommittedWithdraw().withdraw(amount: amountCommitted))

                // update request to show that leftover amount is requested to be unstaked
                stakerRecord.setTokensRequestedToUnstake(stakerRecord.tokensRequestedToUnstake + (amount - amountCommitted))
            }
        }

        /// Requests to unstake all of the staker operators staked and committed tokens
        /// as well as all the staked and committed tokens of all of their delegators
        access(StakerEntitlement)
        fun unstakeAll() {
            pre {
                VenezuelaStaking.stakingEnabled:
                    "Cannot unstake if the staking auction isn't in progress"
            }
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)

            /// if the request can come from committed, withdraw from committed to unstaked
            /// withdraw the requested tokens from committed since they have not been staked yet
            stakerRecord.tokensUnstaked.deposit(from: <- stakerRecord.authTokensCommittedWithdraw().withdraw(amount: stakerRecord.tokensCommitted.balance))
            
            /// update request to show that leftover amount is requested to be unstaked
            stakerRecord.setTokensRequestedToUnstake(stakerRecord.tokensStaked.balance)
        }

        /// Withdraw tokens from the unstaked bucket
        access(StakerEntitlement)
        fun withdrawUnstakedTokens(amount: UFix64): @{FungibleToken.Vault} {
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)
            emit UnstakedTokensWithdrawn(stakerID: stakerRecord.id, amount: amount)
            return <- stakerRecord.authTokensUnstakedWithdraw().withdraw(amount: amount)
        }

        /// Withdraw tokens from the rewarded bucket
        access(StakerEntitlement)
        fun withdrawRewardedTokens(amount: UFix64): @{FungibleToken.Vault} {
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(self.id)

            emit RewardTokensWithdrawn(stakerID: stakerRecord.id, amount: amount)

            return <- stakerRecord.authTokensRewardedWithdraw().withdraw(amount: amount)
        }
    }
    
    /// Admin resource that has the ability to create new staker objects and pay rewards
    /// to stakers at the end of an epoch
    access(all)
    resource Admin {
        
        /// A staker record is created when a VenezuelaPass NFT is created
        /// It returns the resource for stakers that they can store in their account storage
        access(AdminEntitlement)
        fun addStakerRecord(id: UInt64): @Staker {
            pre {
                VenezuelaStaking.stakingEnabled:
                    "Cannot register a staker operator if the staking auction isn't in progress"
            }
            let newStakerRecord <- create StakerRecord(id: id)
            
            // Insert the staker to the table
            VenezuelaStaking.stakers[id] <-! newStakerRecord
            
            // return a new Staker object that the staker operator stores in their account
            return <-create Staker(id: id)
        }
        
        /// Starts the staking auction, the period when stakers and delegators
        /// are allowed to perform staking related operations
        access(AdminEntitlement)
        fun startNewEpoch() {
            VenezuelaStaking.stakingEnabled = true
            VenezuelaStaking.setEpoch(VenezuelaStaking.getEpoch() + 1)
            emit NewEpoch(epoch: VenezuelaStaking.getEpoch(), totalStaked: VenezuelaStaking.getTotalStaked(), totalRewardPayout: VenezuelaStaking.epochTokenPayout)
        }

        /// Starts the staking auction, the period when stakers and delegators
        /// are allowed to perform staking related operations
        access(AdminEntitlement)
        fun startStakingAuction() {
            VenezuelaStaking.stakingEnabled = true
        }

        /// Ends the staking Auction by removing any unapproved stakers
        /// and setting stakingEnabled to false
        access(AdminEntitlement)
        fun endStakingAuction() {
            VenezuelaStaking.stakingEnabled = false
        }

        /// Called at the end of the epoch to pay rewards to staker operators
        /// based on the tokens that they have staked
        access(AdminEntitlement)
        fun payRewards(_ stakerIDs: [UInt64]) {
            pre {
                !VenezuelaStaking.stakingEnabled: "Cannot pay rewards if the staking auction is still in progress"
            }
        // Borrow a reference to the minter object
            let VenezuelaIPMinter = VenezuelaStaking.account.storage.borrow<auth(VenezuelaIP.MinterEntitlement) &VenezuelaIP.Minter>(from: /storage/VenezuelaStakingMinter)
                ?? panic("Could not borrow minter reference")

            // calculate the total number of tokens staked
            var totalStaked = VenezuelaStaking.getTotalStaked()
            if totalStaked == 0.0 {
                return
            }
            var totalRewardScale = VenezuelaStaking.epochTokenPayout / totalStaked
            let epoch = VenezuelaStaking.getEpoch()
            let epochPath = VenezuelaStaking.getStakingRewardPath(epoch: epoch)
            var stakingRewardRecordsRefOpt = VenezuelaStaking.account.storage.borrow<auth(Mutate) &{String: Bool}>(from: epochPath)
            if stakingRewardRecordsRefOpt == nil {
                VenezuelaStaking.account.storage.save<{String: Bool}>({}, to: epochPath)
                stakingRewardRecordsRefOpt = VenezuelaStaking.account.storage.borrow<auth(Mutate) &{String: Bool}>(from: epochPath)
            }
            var stakingRewardRecordsRef = stakingRewardRecordsRefOpt!

            /// iterate through stakers to pay
            for stakerID in stakerIDs {
                // add reward record
                let key = VenezuelaStaking.getStakingRewardKey(epoch: epoch, stakerID: stakerID)
                if stakingRewardRecordsRef[key] != nil && stakingRewardRecordsRef[key]! {
                    continue
                }
                stakingRewardRecordsRef[key] = true
                let stakerRecord = VenezuelaStaking.borrowStakerRecord(stakerID)
                if stakerRecord.tokensStaked.balance == 0.0 { continue }
                let rewardAmount = stakerRecord.tokensStaked.balance * totalRewardScale
                if rewardAmount == 0.0 { continue }
                emit RewardsPaid(stakerID: stakerRecord.id, amount: rewardAmount)

                /// Deposit the staker Rewards into their tokensRewarded bucket
                stakerRecord.tokensRewarded.deposit(from: <- VenezuelaIPMinter.mintTokens(amount: rewardAmount))
            }
        }

        /// Called at the end of the epoch to move tokens between buckets
        /// for stakers
        /// Tokens that have been committed are moved to the staked bucket
        /// Tokens that were unstaking during the last epoch are fully unstaked
        /// Unstaking requests are filled by moving those tokens from staked to unstaking
        access(AdminEntitlement)
        fun moveTokens(_ stakerIDs: [UInt64]) {
            pre {
                !VenezuelaStaking.stakingEnabled: "Cannot move tokens if the staking auction is still in progress"
            }
            for stakerID in stakerIDs {
                // get staker record
                let stakerRecord = VenezuelaStaking.borrowStakerRecord(stakerID)

                // Update total number of tokens staked by all the stakers of each type
                VenezuelaStaking.totalTokensStaked = VenezuelaStaking.totalTokensStaked + stakerRecord.tokensCommitted.balance

                // mark the committed tokens as staked
                if stakerRecord.tokensCommitted.balance > 0.0 {
                    emit TokensStaked(stakerID: stakerRecord.id, amount: stakerRecord.tokensCommitted.balance)
                    stakerRecord.tokensStaked.deposit(from: <-stakerRecord.authTokensCommittedWithdraw().withdraw(amount: stakerRecord.tokensCommitted.balance))
                }

                // unstake the requested tokens and move them to tokensUnstaking
                if stakerRecord.tokensRequestedToUnstake > 0.0 {
                    emit TokensUnstaked(stakerID: stakerRecord.id, amount: stakerRecord.tokensRequestedToUnstake)
                    stakerRecord.tokensUnstaked.deposit(from: <-stakerRecord.authTokensStakedWithdraw().withdraw(amount: stakerRecord.tokensRequestedToUnstake))

                    // subtract their requested tokens from the total staked for their staker type
                    VenezuelaStaking.totalTokensStaked = VenezuelaStaking.totalTokensStaked - stakerRecord.tokensRequestedToUnstake
                    
                    // Reset the tokens requested field so it can be used for the next epoch
                    stakerRecord.setTokensRequestedToUnstake(0.0)
                }
                emit MoveToken(stakerID: stakerID)
            }
        }

        /// Changes the total weekly payout to a new value
        access(AdminEntitlement)
        fun setEpochTokenPayout(_ newPayout: UFix64) {
            VenezuelaStaking.epochTokenPayout = newPayout
            emit NewWeeklyPayout(newPayout: newPayout)
        }

        access(AdminEntitlement)
        fun createNewAdmin(): @Admin {
            emit AdminCreated()
            return <-create Admin()
        }
    }

    /// borrow a reference to to one of the stakers in the record
    access(account)
    view fun borrowStakerRecord(_ stakerID: UInt64): &StakerRecord {
        pre {
            VenezuelaStaking.stakers[stakerID] != nil:
                "Specified staker ID does not exist in the record"
        }
        return (&VenezuelaStaking.stakers[stakerID] as &StakerRecord?)!
    }

    /// Gets an array of all the stakerIDs that are staked.
    /// Only stakers that are participating in the current epoch
    /// can be staked, so this is an array of all the active stakers
    access(all)
    fun getStakedStakerIDs(): [UInt64] {
        var stakers: [UInt64] = []
        for stakerID in VenezuelaStaking.getStakerIDs() {
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(stakerID)
            if stakerRecord.tokensStaked.balance > 0.0 {
                stakers.append(stakerID)
            }
        }
        return stakers
    }

    /// Gets an slice of stakerIDs who's staking balance > 0
    access(all)
    fun getStakedStakerIDsSlice(start: UInt64, end: UInt64): [UInt64] {
        // all staker ids
        var allStakerIDs: [UInt64] = VenezuelaStaking.getStakerIDs()

        // output
        var stakers: [UInt64] = []

        // filter staker ids by staking balance
        var current = start
        while current < end {
            let stakerID = allStakerIDs[current]
            let stakerRecord = VenezuelaStaking.borrowStakerRecord(stakerID)
            if stakerRecord.tokensStaked.balance > 0.0 {
                stakers.append(stakerID)
            }
            current = current + 1
        }
        return stakers
    }

    /// Gets an array of all the staker IDs that have ever registered
    access(all)
    fun getStakerIDs(): [UInt64] {
        return VenezuelaStaking.stakers.keys
    }

    /// Gets an slice of stakerIDs who's staking balance > 0
    access(all)
    fun getStakerIDsSlice(start: UInt64, end: UInt64): [UInt64] {
        // all staker ids
        var allStakerIDs: [UInt64] = VenezuelaStaking.getStakerIDs()

        // output
        var stakers: [UInt64] = []

        // filter staker ids by staking balance
        var current = start
        while current < end {
            stakers.append(allStakerIDs[current])
            current = current + 1
        }
        return stakers
    }

    /// Gets staker id count
    access(all)
    fun getStakerIDCount(): Int {
        return VenezuelaStaking.stakers.keys.length
    }

    /// Gets the token payout value for the current epoch
    access(all)
    fun getEpochTokenPayout(): UFix64 {
        return self.epochTokenPayout
    }

    access(all)
    fun getStakingEnabled(): Bool {
        return self.stakingEnabled
    }

    /// Gets the total number of VZLA that is currently staked
    /// by all of the staked stakers in the current epoch
    access(all)
    fun getTotalStaked(): UFix64 {
        return VenezuelaStaking.totalTokensStaked
    }

    /// Epoch
    access(all)
    fun getEpoch(): UInt64 {
        return self.account.storage.copy<UInt64>(from: /storage/VenezuelaStakingEpoch) ?? 0
    }

    access(contract)
    fun setEpoch(_ epoch: UInt64) {
        self.account.storage.load<UInt64>(from: /storage/VenezuelaStakingEpoch)
        self.account.storage.save<UInt64>(epoch, to: /storage/VenezuelaStakingEpoch)
    }
    
    access(contract)
    fun getStakingRewardKey(epoch: UInt64, stakerID: UInt64): String {
        // key: {EPOCH}_{STAKER_ID}
        return epoch.toString().concat("_").concat(stakerID.toString())
    }

    access(contract)
    fun getStakingRewardPath(epoch: UInt64): StoragePath {
        // path: /storage/VenezuelaStakingStakingRewardRecords_{EPOCH}
        return StoragePath(identifier: "VenezuelaStakingStakingRewardRecords".concat("_").concat(epoch.toString()))!
    }

    /// staking reward records
    access(all)
    fun hasSentStakingReward(epoch: UInt64, stakerID: UInt64): Bool {
        let stakingRewardRecordsRef = self.account.storage.borrow<&{String: Bool}>(from: VenezuelaStaking.getStakingRewardPath(epoch: epoch))
        if stakingRewardRecordsRef == nil {
            return false
        }
        let key = VenezuelaStaking.getStakingRewardKey(epoch: epoch, stakerID: stakerID)
        if stakingRewardRecordsRef![key] == nil {
            return false
        }

        return stakingRewardRecordsRef![key]!
    }

    init() {
        self.stakingEnabled = true

        self.stakers <- {}

        self.StakingAdminStoragePath = /storage/VenezuelaStakingAdmin

        self.totalTokensStaked = 0.0
        self.epochTokenPayout = 1.0

        self.account.storage.save(<-create Admin(), to: self.StakingAdminStoragePath)
    }
}