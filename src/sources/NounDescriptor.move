module suinouns::NounDescriptor {
    use std::string::{Self, String};
    use std::ascii;

    use sui::vec_map::{Self, VecMap};
    use sui::event;
    use sui::bcs;

    use suinouns::ownable::{Self, Ownership};
    use suinouns::nft_descriptor;

    public struct Descriptor has key {
        id: UID,
        // Whether or not new Noun parts can be added
        are_parts_locked: bool,
        // Whether or not `tokenURI` should be returned as a data URI (Default: true)
        is_data_uri_enabled : bool, // true;
        // Base URI
        base_uri: String,
        // Noun Color Palettes (Index => Hex Colors)
        palettes: VecMap<u8, vector<String>>,
        // Noun Backgrounds (Hex Colors)
        bg_colors: vector<String>,
        // Noun Backgrounds (Hex Colors)
        backgrounds: vector<vector<u8>>,
        // Noun Bodies (Custom RLE)
        bodies: vector<vector<u8>>,
        // Noun Accessories (Custom RLE)
        accessories: vector<vector<u8>>,
        // Noun Heads (Custom RLE)
        heads: vector<vector<u8>>,
        // Noun Eyes (Custom RLE)
        eyes: vector<vector<u8>>,
        // Noun Eyes (Custom RLE)
        mouths: vector<vector<u8>>,
        // Noun Backgrounds (Hex Colors)
        background_names: vector<String>,
        // Noun Bodies (Custom RLE)
        body_names: vector<String>,
        // Noun Accessories (Custom RLE)
        accessory_names: vector<String>,
        // Noun Heads (Custom RLE)
        head_names: vector<String>,
        // Noun Eyes (Custom RLE)
        eyes_names: vector<String>,
        // Noun Eyes (Custom RLE)
        mouth_names: vector<String>,
    }

    public struct Seed {
        background: u64,
        body: u64,
        accessory: u64,
        head: u64,
        eyes: u64,
        mouth: u64,
    }

    public struct PartsLocked has copy, drop {}

    public struct DataURIToggled has copy, drop {
        enabled: bool,
    }

    public struct BaseURIUpdated has copy, drop {
        base_uri: String,
    }

    const ERR_PARTS_LOCKED: u64 = 100;
    const ERR_PALETTE_FULL: u64 = 101;

    fun assert_parts_not_locked(descriptor: &Descriptor) {
        assert!(descriptor.are_parts_locked == false, ERR_PARTS_LOCKED)
    }

    fun init(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let descriptor = Descriptor {
            id: object::new(ctx),
            are_parts_locked: false,
            is_data_uri_enabled: true,
            base_uri: string::utf8(b"https://nouns.wtf/"),
            palettes: vec_map::empty(),
            bg_colors: vector::empty(),
            backgrounds: vector::empty(),
            bodies: vector::empty(),
            accessories: vector::empty(),
            heads: vector::empty(),
            eyes: vector::empty(),
            mouths: vector::empty(),
            background_names: vector::empty(),
            body_names: vector::empty(),
            accessory_names: vector::empty(),
            head_names: vector::empty(),
            eyes_names: vector::empty(),
            mouth_names: vector::empty(),
        };

        transfer::transfer(descriptor, sender);
    }

    public fun background_count(descriptor: &Descriptor): u64 {
        return descriptor.backgrounds.length()
    }

    public fun bg_colors_count(descriptor: &Descriptor): u64 {
        return descriptor.bg_colors.length()
    }

    public fun body_count(descriptor: &Descriptor): u64 {
        return descriptor.bodies.length()
    }

    public fun accessory_count(descriptor: &Descriptor): u64 {
        return descriptor.accessories.length()
    }

    public fun head_count(descriptor: &Descriptor): u64 {
        return descriptor.heads.length()
    }

    public fun eyes_count(descriptor: &Descriptor): u64 {
        return descriptor.eyes.length()
    }

    public fun mouth_count(descriptor: &Descriptor): u64 {
        return descriptor.mouths.length()
    }

    public fun add_many_colors_to_palette(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        palette_index: u8, 
        new_colors: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        let palettes = descriptor.palettes;
        let palette = *vec_map::get(&palettes, &palette_index);
        let palette_length = palette.length();
        assert!(palette_length + new_colors.length() <= 264, ERR_PALETTE_FULL);
        let mut i = 0;
        while ( i < new_colors.length() ) {
            add_color_to_palette_internal(descriptor, palette_index, new_colors[i]);
            i = i + 1;
        };
    }

    public fun add_many_bg_colors(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_colors: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_colors.length() ) {
            add_bg_color_internal(descriptor, new_colors[i]);
            i = i + 1;
        };
    }

    public fun add_many_backgrounds(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_backgrounds: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_backgrounds.length() ) {
            add_background_internal(descriptor, new_backgrounds[i]);
            i = i + 1;
        };
    }

    public fun add_many_bodies(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_bodies: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_bodies.length() ) {
            add_body_internal(descriptor, new_bodies[i]);
            i = i + 1;
        };
    }

    public fun add_many_accessories(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_accessories: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_accessories.length() ) {
            add_accessory_internal(descriptor, new_accessories[i]);
            i = i + 1;
        };
    }

    public fun add_many_heads(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_heads: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_heads.length() ) {
            add_head_internal(descriptor, new_heads[i]);
            i = i + 1;
        };
    }

    public fun add_many_eyes(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_eyes: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_eyes.length() ) {
            add_eyes_internal(descriptor, new_eyes[i]);
            i = i + 1;
        };
    }

    public fun add_many_mouths(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_mouths: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_mouths.length() ) {
            add_mouth_internal(descriptor, new_mouths[i]);
            i = i + 1;
        };
    }

    public fun add_many_background_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_background_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_many_body_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_body_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_many_accessory_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_accessory_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_many_head_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_head_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_many_eyes_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_eyes_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_many_mouth_names(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_names: vector<String>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        let mut i = 0;
        while ( i < new_names.length() ) {
            add_mouth_name_internal(descriptor, new_names[i]);
            i = i + 1;
        };
    }

    public fun add_color_to_palette(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        palette_index: u8, 
        new_color: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        add_color_to_palette_internal(descriptor, palette_index, new_color);
    }

    public fun add_bg_color(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_color: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_bg_color_internal(descriptor, new_color);
    }

    public fun add_background(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_background: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_background_internal(descriptor, new_background);
    }

    public fun add_body(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_body: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_body_internal(descriptor, new_body);
    }

    public fun add_accessory(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_accessory: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_accessory_internal(descriptor, new_accessory);
    }

    public fun add_head(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_head: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_head_internal(descriptor, new_head);
    }

    public fun add_eyes(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_eyes: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_eyes_internal(descriptor, new_eyes);
    }

    public fun add_mouth(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_mouth: vector<u8>,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_mouth_internal(descriptor, new_mouth);
    }

    public fun add_background_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_background_name_internal(descriptor, new_name);
    }

    public fun add_body_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_body_name_internal(descriptor, new_name);
    }

    public fun add_accessory_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_accessory_name_internal(descriptor, new_name);
    }

    public fun add_head_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_head_name_internal(descriptor, new_name);
    }

    public fun add_eyes_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_eyes_name_internal(descriptor, new_name);
    }

    public fun add_mouth_name(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_name: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        add_mouth_name_internal(descriptor, new_name);
    }

    public fun lock_parts(
        ownership: &Ownership, 
        descriptor: &mut Descriptor,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        assert_parts_not_locked(descriptor);
        descriptor.are_parts_locked = true;

        event::emit(
            PartsLocked {}
        );
    }

    public fun toggle_data_uri(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        let enabled;
        if (descriptor.is_data_uri_enabled) {
            descriptor.is_data_uri_enabled = false;
            enabled = false;
        } else {
            descriptor.is_data_uri_enabled = true;
            enabled = true;
        };

        event::emit(
            DataURIToggled { enabled: enabled }
        );
    }

    public fun set_base_uri(
        ownership: &Ownership, 
        descriptor: &mut Descriptor, 
        new_base_uri: String,
        ctx: &mut TxContext
    ) {
        ownable::only_owner(ownership, ctx);
        descriptor.base_uri = new_base_uri;

        event::emit(
            BaseURIUpdated { base_uri: new_base_uri }
        );
    }

    public fun token_uri(descriptor: &Descriptor, token_id: u256, seed: &Seed): String {
        if (descriptor.is_data_uri_enabled) {
            return data_uri(descriptor, token_id, seed)
        };

        let noun_id = bcs::to_bytes(&token_id);

        let mut base_uri = descriptor.base_uri;

        string::append_utf8(&mut base_uri, noun_id);

        return base_uri
    }

    public fun data_uri(descriptor: &Descriptor, token_id: u256, seed: &Seed): String {
        let noun_id = bcs::to_bytes(&token_id);
        let mut name = string::utf8(b"Noun ");
        let mut description = string::utf8(b"Noun ");
        string::append_utf8(&mut name, noun_id);
        string::append_utf8(&mut description, noun_id);
        string::append_utf8(&mut description, b" is a member of Nouns DAO.");

        return generic_data_uri(descriptor, name, description, seed)
    }

    public fun generic_data_uri(
        descriptor: &Descriptor,
        name: String,
        description: String, 
        seed: &Seed
    ): String {
        let parts = get_parts_for_seed(descriptor, seed);
        let background = *vector::borrow(&descriptor.bg_colors, seed.background);

        let names = get_attributes_for_seed(descriptor, seed);

        let data = nft_descriptor::construct_token_uri(
            name,
            description,
            parts,
            background,
            names
        );

        return string::utf8(data)
    }

    public fun generate_svg_image(descriptor: &Descriptor, seed: &Seed): String {
        let parts = get_parts_for_seed(descriptor, seed);
        let background = *vector::borrow(&descriptor.bg_colors, seed.background);

        let to_ascii = string::to_ascii(background);
        let to_bytes = ascii::into_bytes(to_ascii);

        let image = nft_descriptor::generate_svg_image(parts, to_bytes);

        return string::utf8(image)
    }

    fun add_color_to_palette_internal(
        descriptor: &mut Descriptor, 
        palette_index: u8, 
        new_color: String
    ) {
        let palettes = &mut descriptor.palettes;
        let palette = vec_map::get_mut(palettes, &palette_index);
        vector::push_back(palette, new_color);
    }

    fun add_bg_color_internal(descriptor: &mut Descriptor, new_color: String) {
        vector::push_back(&mut descriptor.bg_colors, new_color);
    }

    fun add_background_internal(descriptor: &mut Descriptor, new_background: vector<u8>) {
        vector::push_back(&mut descriptor.backgrounds, new_background);
    }

    fun add_body_internal(descriptor: &mut Descriptor, new_body: vector<u8>) {
        vector::push_back(&mut descriptor.bodies, new_body);
    }

    fun add_accessory_internal(descriptor: &mut Descriptor, new_accessory: vector<u8>) {
        vector::push_back(&mut descriptor.accessories, new_accessory);
    }

    fun add_head_internal(descriptor: &mut Descriptor, new_head: vector<u8>) {
        vector::push_back(&mut descriptor.heads, new_head);
    }

    fun add_eyes_internal(descriptor: &mut Descriptor, new_eyes: vector<u8>) {
        vector::push_back(&mut descriptor.eyes, new_eyes);
    }

    fun add_mouth_internal(descriptor: &mut Descriptor, new_mouth: vector<u8>) {
        vector::push_back(&mut descriptor.mouths, new_mouth);
    }

    fun add_background_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.background_names, new_name);
    }

    fun add_body_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.body_names, new_name);
    }

    fun add_accessory_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.accessory_names, new_name);
    }

    fun add_head_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.head_names, new_name);
    }

    fun add_eyes_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.eyes_names, new_name);
    }

    fun add_mouth_name_internal(descriptor: &mut Descriptor, new_name: String) {
        vector::push_back(&mut descriptor.mouth_names, new_name);
    }

    fun get_parts_for_seed(
        descriptor: &Descriptor, 
        seed: &Seed
    ): vector<vector<u8>> {
        let mut parts = vector::empty<vector<u8>>();
        vector::push_back(&mut parts, *vector::borrow(&descriptor.backgrounds, seed.background));
        vector::push_back(&mut parts, *vector::borrow(&descriptor.bodies, seed.body));
        vector::push_back(&mut parts, *vector::borrow(&descriptor.accessories, seed.accessory));
        vector::push_back(&mut parts, *vector::borrow(&descriptor.heads, seed.head));
        vector::push_back(&mut parts, *vector::borrow(&descriptor.eyes, seed.eyes));
        vector::push_back(&mut parts, *vector::borrow(&descriptor.mouths, seed.mouth));
        return parts
    }

    fun get_attributes_for_seed(
        descriptor: &Descriptor, 
        seed: &Seed
    ): vector<String> {
        let mut attributes = vector::empty<String>();
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.background_names, seed.background));
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.body_names, seed.body));
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.accessory_names, seed.accessory));
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.head_names, seed.head));
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.eyes_names, seed.eyes));
        vector::push_back(&mut attributes, *vector::borrow(&descriptor.mouth_names, seed.mouth));
        return attributes
    }
}