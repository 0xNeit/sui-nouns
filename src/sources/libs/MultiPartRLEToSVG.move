

/// @title A library used to convert multi-part RLE compressed images to SVG
/// @dev Used in NFTDescriptor.move.

module suinouns::MultiPartRLEToSVG {
    use std::string::String;
    use std::vector;

    struct SVGParams {
        parts: vector<vector<u8>>,
        background: String
    }

    struct ContentBounds has store {
        top: u8,
        right: u8,
        bottom: u8,
        left: u8
    }

    struct Rect has store {
        length: u8,
        colorIndex: u8
    }

    struct DecodedImage {
        paletteIndex: u8,
        bounds: ContentBounds,
        rects: vector<Rect>
    }

    /**
     * @notice Given RLE image parts and color palettes, merge to generate a single SVG image.
     */
    /*public fun generateSVG(params: SVGParams, mapping(uint8 => string[]) storage palettes)
        internal
        view
        returns (string memory svg)
    {
        // prettier-ignore
        return string(
            abi.encodePacked(
                '<svg width="320" height="320" viewBox="0 0 320 320" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">',
                '<rect width="100%" height="100%" fill="#', params.background, '" />',
                _generateSVGRects(params, palettes),
                '</svg>'
            )
        );
    }*/

    /**
     * @notice Given RLE image parts and color palettes, generate SVG rects.
     */
    // prettier-ignore
    /*public fun _generateSVGRects(SVGParams memory params, mapping(uint8 => string[]) storage palettes)
        private
        view
        returns (string memory svg)
    {
        string[33] memory lookup = [
            '0', '10', '20', '30', '40', '50', '60', '70', 
            '80', '90', '100', '110', '120', '130', '140', '150', 
            '160', '170', '180', '190', '200', '210', '220', '230', 
            '240', '250', '260', '270', '280', '290', '300', '310',
            '320' 
        ];
        string memory rects;
        for (uint8 p = 0; p < params.parts.length; p++) {
            DecodedImage memory image = _decodeRLEImage(params.parts[p]);
            string[] storage palette = palettes[image.paletteIndex];
            uint256 currentX = image.bounds.left;
            uint256 currentY = image.bounds.top;
            uint256 cursor;
            string[16] memory buffer;

            string memory part;
            for (uint256 i = 0; i < image.rects.length; i++) {
                Rect memory rect = image.rects[i];
                if (rect.colorIndex != 0) {
                    buffer[cursor] = lookup[rect.length];          // width
                    buffer[cursor + 1] = lookup[currentX];         // x
                    buffer[cursor + 2] = lookup[currentY];         // y
                    buffer[cursor + 3] = palette[rect.colorIndex]; // color

                    cursor += 4;

                    if (cursor >= 16) {
                        part = string(abi.encodePacked(part, _getChunk(cursor, buffer)));
                        cursor = 0;
                    }
                }

                currentX += rect.length;
                if (currentX == image.bounds.right) {
                    currentX = image.bounds.left;
                    currentY++;
                }
            }

            if (cursor != 0) {
                part = string(abi.encodePacked(part, _getChunk(cursor, buffer)));
            }
            rects = string(abi.encodePacked(rects, part));
        }
        return rects;
    }*/

    /**
     * @notice Return a string that consists of all rects in the provided `buffer`.
     */
    // prettier-ignore
    /*public fun _getChunk(uint256 cursor, string[16] memory buffer) private pure returns (string memory) {
        string memory chunk;
        for (uint256 i = 0; i < cursor; i += 4) {
            chunk = string(
                abi.encodePacked(
                    chunk,
                    '<rect width="', buffer[i], '" height="10" x="', buffer[i + 1], '" y="', buffer[i + 2], '" fill="#', buffer[i + 3], '" />'
                )
            );
        }
        return chunk;
    }*/

    /**
     * @notice Decode a single RLE compressed image into a `DecodedImage`.
     */
    public fun decodeRLEImage_(image: vector<u8>): DecodedImage {
        // extract palette index from byte array
        let paletteIndex = *vector::borrow(&image, 0);

        // extract content bounds from byte array
        let bounds = ContentBounds {
                        top: *vector::borrow(&image, 1),
                        right: *vector::borrow(&image, 2),
                        bottom: *vector::borrow(&image, 3),
                        left: *vector::borrow(&image, 4)
                    };

        // extract rect information from byte array
        let len = vector::length(&image);
        // let rect_count = (len - 5) / 2;
        let rects = vector::empty<Rect>();
        let cursor = 0;
        let i = 5;
        while (i < len) {
            let new_rect = Rect {
                                length: *vector::borrow(&image, i),
                                colorIndex: *vector::borrow(&image, i + 1)
                            };
            vector::insert(&mut rects, new_rect, cursor);
            cursor = cursor + 1;
            i = i + 2;
        };
        
        return DecodedImage {
                    paletteIndex: paletteIndex,
                    bounds: bounds,
                    rects: rects 
                }
    }
}
