module suinouns::nft_descriptor {
    use std::ascii;
    use std::string::{Self, String};

    use suinouns::base64;
    use suinouns::multipart_rle_to_svg;

    /**
     * @notice Construct an NFT token URI.
     */
    public fun construct_token_uri(
        name: String,
        description: String,
        parts: vector<vector<u8>>,
        background: String,
        names: vector<String>
    ): vector<u8> {
        let parts = parts;
        let bg = ascii::into_bytes(string::to_ascii(background));
        
        let image = generate_svg_image(parts, bg);

        let attributes = generate_attributes(names);

        let mut bytes = string::utf8(b"");
        let first_byte = string::utf8(b"{'name':'}");
        let second_byte = name;
        let third_byte = string::utf8(b"', 'description':'");
        let fourth_byte = description;
        let fifth_byte = string::utf8(b"', 'image':'");
        let sixth_byte = string::utf8(b"data:image/svg+xml;base64,");
        let seventh_byte = image;
        let eighth_byte = string::utf8(b",");
        let ninth_byte = string::utf8(b"', 'attributes':");
        let tenth_byte = string::utf8(b", ");
        let eleventh_byte = attributes;
        let twelveth_byte = string::utf8(b"}");
        string::append(&mut bytes, first_byte);
        string::append(&mut bytes, second_byte);
        string::append(&mut bytes, third_byte);
        string::append(&mut bytes, fourth_byte);
        string::append(&mut bytes, fifth_byte);
        string::append(&mut bytes, sixth_byte);
        string::append_utf8(&mut bytes, seventh_byte);
        string::append(&mut bytes, eighth_byte);
        string::append(&mut bytes, ninth_byte);
        string::append(&mut bytes, tenth_byte);
        string::append_utf8(&mut bytes, eleventh_byte);
        string::append(&mut bytes, twelveth_byte);
        
        let encoded = base64::encode(ascii::into_bytes(string::to_ascii(bytes)));

        let mut uri = string::utf8(b"data:application/json;base64,");
        string::append_utf8(&mut uri, encoded);

        let uri_bytes = ascii::into_bytes(string::to_ascii(uri));

        return uri_bytes
    }

    /**
     * @notice Generate an SVG image for use in the NFT token URI.
     */
    public fun generate_svg_image(parts: vector<vector<u8>>, background: vector<u8>): vector<u8> {
        let svg = multipart_rle_to_svg::generate_svg(parts, background);
        let encoded = base64::encode(svg);
        return encoded
    }

    fun string_to_vector(s: String): vector<u8> {
        let bytes = ascii::into_bytes(string::to_ascii(s));
        return bytes
    }

    public fun generate_attributes(attributes: vector<String>): vector<u8> {
        let mut traits = string::utf8(b"");
        let attribute1 = *vector::borrow(&attributes, 0);
        let attribute2 = *vector::borrow(&attributes, 1);
        let attribute3 = *vector::borrow(&attributes, 2);
        let attribute4 = *vector::borrow(&attributes, 3);
        let attribute5 = *vector::borrow(&attributes, 4);
        let attribute6 = *vector::borrow(&attributes, 5);
        let background = attribute_for_type_and_value(b"Background", string_to_vector(attribute1));
        let body = attribute_for_type_and_value(b"Body", string_to_vector(attribute2));
        let bristles = attribute_for_type_and_value(b"Bristles", string_to_vector(attribute3));
        let accessory = attribute_for_type_and_value(b"Accessory", string_to_vector(attribute4));
        let eyes = attribute_for_type_and_value(b"Eyes", string_to_vector(attribute5));
        let mouth = attribute_for_type_and_value(b"Mouth", string_to_vector(attribute6));
        string::append_utf8(&mut traits, background);
        string::append_utf8(&mut traits, body);
        string::append_utf8(&mut traits, bristles);
        string::append_utf8(&mut traits, accessory);
        string::append_utf8(&mut traits, eyes);
        string::append_utf8(&mut traits, mouth);
        
        let mut attr = string::utf8(b"[");
        string::append(&mut attr, traits);
        string::append_utf8(&mut attr, b"]");

        let attr_bytes = string::to_ascii(attr);
        let bytes = ascii::into_bytes(attr_bytes); 

        return bytes
    }

    fun attribute_for_type_and_value(traitType: vector<u8>, value: vector<u8>): vector<u8> {
        let mut new_string = string::utf8(b"");
        string::append_utf8(&mut new_string, b"{'trait_type':'");
        string::append_utf8(&mut new_string, traitType);
        string::append_utf8(&mut new_string, b"','value':'");
        string::append_utf8(&mut new_string, value);
        string::append_utf8(&mut new_string, b"'}");

        let bytes = string::to_ascii(new_string);
        let ascii_bytes = ascii::into_bytes(bytes);
        
        return ascii_bytes
    }
}