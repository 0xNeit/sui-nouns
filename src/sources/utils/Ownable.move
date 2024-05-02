module suinouns::ownable {
    use sui::event;

    public struct Ownership has key {
        id: UID,
        owner: address
    }

    public struct OwnershipTransferred has copy, drop {
        previous_owner: address,
        new_owner: address
    }

    const ERR_NOT_OWNER: u64 = 0;
    const ERR_ZERO_ADDRESS: u64 = 1;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    fun init(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let ownership = Ownership {
            id: object::new(ctx),
            owner: sender
        };
        transfer::transfer(ownership, sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    public fun only_owner(owner: &Ownership, ctx: &mut TxContext) {
        check_owner(owner, ctx);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    public fun owner(ownership: &Ownership): address {
        let own = ownership.owner;
        return own
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    fun check_owner(ownership: &Ownership, ctx: &TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(owner(ownership) == sender, ERR_NOT_OWNER);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` public funs. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any public funality that is only available to the owner.
     */
    public fun renounce_ownership(owner: &mut Ownership, ctx: &mut TxContext) {
        only_owner(owner, ctx);
        transfer_ownership_internal(owner, @0x0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    public fun transfer_ownership(owner: &mut Ownership, new_owner: address, ctx: &mut TxContext) {
        only_owner(owner, ctx);
        assert!(new_owner != @0x0, ERR_ZERO_ADDRESS);
        transfer_ownership_internal(owner, new_owner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal public fun without access restriction.
     */
    fun transfer_ownership_internal(owner: &mut Ownership, new_owner: address) {
        owner.owner = new_owner;
        
        event::emit(
            OwnershipTransferred {
                previous_owner: owner.owner,
                new_owner: new_owner
            }
        );
    }
}
