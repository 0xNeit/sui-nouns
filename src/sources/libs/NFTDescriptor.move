module suinouns::NFTDescriptor {
    use std::ascii;
    use std::string;
    use std::vector;

    use suinouns::Base64;
    use suinouns::MultiPartRLEToSVG;

    struct TokenURIParams has drop {
        name: vector<u8>,
        description: vector<u8>,
        parts: vector<vector<u8>>,
        background: vector<u8>,
        names: vector<vector<u8>>
    }

    /**
     * @notice Construct an ERC721 token URI.
     */
    public fun constructTokenURI(params: TokenURIParams): vector<u8> {
        let parts = params.parts;
        let background = params.background;
        
        let image = generateSVGImage(parts, background);

        let attributes = generateAttributes(params.names);

        let bytes = string::utf8(b"");
        let first_byte = string::utf8(b"{'name':'}");
        let second_byte = params.name;
        let third_byte = string::utf8(b"', 'description':'");
        let fourth_byte = params.description;
        let fifth_byte = string::utf8(b"', 'image':'");
        let sixth_byte = string::utf8(b"data:image/svg+xml;base64,");
        let seventh_byte = image;
        let eighth_byte = string::utf8(b",");
        let ninth_byte = string::utf8(b"', 'attributes':");
        let tenth_byte = string::utf8(b", ");
        let eleventh_byte = attributes;
        let twelveth_byte = string::utf8(b"}");
        string::append(&mut bytes, first_byte);
        string::append_utf8(&mut bytes, second_byte);
        string::append(&mut bytes, third_byte);
        string::append_utf8(&mut bytes, fourth_byte);
        string::append(&mut bytes, fifth_byte);
        string::append(&mut bytes, sixth_byte);
        string::append_utf8(&mut bytes, seventh_byte);
        string::append(&mut bytes, eighth_byte);
        string::append(&mut bytes, ninth_byte);
        string::append(&mut bytes, tenth_byte);
        string::append_utf8(&mut bytes, eleventh_byte);
        string::append(&mut bytes, twelveth_byte);
        
        let encoded = Base64::encode(ascii::into_bytes(string::to_ascii(bytes)));

        let uri = string::utf8(b"data:application/json;base64,");
        string::append_utf8(&mut uri, encoded);

        let uri_bytes = ascii::into_bytes(string::to_ascii(uri));

        return uri_bytes
    }

    /**
     * @notice Generate an SVG image for use in the ERC721 token URI.
     */
    public fun generateSVGImage(parts: vector<vector<u8>>, background: vector<u8>): vector<u8> {
        let svg = MultiPartRLEToSVG::generateSVG(parts, background);
        let encoded = Base64::encode(svg);
        return encoded
    }

    public fun generateAttributes(attributes: vector<vector<u8>>): vector<u8> {
        let traits = string::utf8(b"");
        let attribute1 = *vector::borrow(&attributes, 0);
        let attribute2 = *vector::borrow(&attributes, 1);
        let attribute3 = *vector::borrow(&attributes, 2);
        let attribute4 = *vector::borrow(&attributes, 3);
        let attribute5 = *vector::borrow(&attributes, 4);
        let attribute6 = *vector::borrow(&attributes, 5);
        let background = attributeForTypeAndValue(b"Background", attribute1);
        let body = attributeForTypeAndValue(b"Body", attribute2);
        let bristles = attributeForTypeAndValue(b"Bristles", attribute3);
        let accessory = attributeForTypeAndValue(b"Accessory", attribute4);
        let eyes = attributeForTypeAndValue(b"Eyes", attribute5);
        let mouth = attributeForTypeAndValue(b"Mouth", attribute6);
        string::append_utf8(&mut traits, background);
        string::append_utf8(&mut traits, body);
        string::append_utf8(&mut traits, bristles);
        string::append_utf8(&mut traits, accessory);
        string::append_utf8(&mut traits, eyes);
        string::append_utf8(&mut traits, mouth);
        
        let attr = string::utf8(b"[");
        string::append(&mut attr, traits);
        string::append_utf8(&mut attr, b"]");

        let attr_bytes = string::to_ascii(attr);
        let bytes = ascii::into_bytes(attr_bytes); 

        return bytes
    }

    public fun attributeForTypeAndValue(traitType: vector<u8>, value: vector<u8>): vector<u8> {
        let new_string = string::utf8(b"");
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