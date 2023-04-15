module suinouns::Ownable {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;

    struct Ownership has key {
        id: UID,
        owner: address
    }

    struct OwnershipTransferred has copy, drop {
        previousOwner: address,
        newOwner: address
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
    public fun onlyOwner(owner: &Ownership, ctx: &mut TxContext) {
        checkOwner_(owner, ctx);
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
    fun checkOwner_(ownership: &Ownership, ctx: &mut TxContext) {
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
    public fun renounceOwnership(owner: &mut Ownership, ctx: &mut TxContext) {
        onlyOwner(owner, ctx);
        transferOwnership_(owner, @0x0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    public fun transferOwnership(owner: &mut Ownership, newOwner: address, ctx: &mut TxContext) {
        onlyOwner(owner, ctx);
        assert!(newOwner != @0x0, ERR_ZERO_ADDRESS);
        transferOwnership_(owner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal public fun without access restriction.
     */
    fun transferOwnership_(owner: &mut Ownership, newOwner: address) {
        owner.owner = newOwner;
        
        event::emit(
            OwnershipTransferred {
                previousOwner: owner.owner,
                newOwner: newOwner
            }
        );
    }
}
