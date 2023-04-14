

/// @title A library used to convert multi-part RLE compressed images to SVG
/// @dev Used in NFTDescriptor.move.

module suinouns::MultiPartRLEToSVG {
    use std::string::{Self, String};
    use std::vector;

    use sui::bcs;
    // use sui::table::{Self, Table};

    struct SVGParams has drop {
        parts: vector<vector<u8>>,
        background: String
    }

    struct ContentBounds has drop, store {
        top: u8,
        right: u8,
        bottom: u8,
        left: u8
    }

    struct Rect has copy, drop, store {
        length: u8,
        colorIndex: u8
    }

    struct DecodedImage has drop {
        paletteIndex: u8,
        bounds: ContentBounds,
        rects: vector<Rect>
    }

    /**
     * @notice Given RLE image parts and color palettes, merge to generate a single SVG image.
     */
    public fun generateSVG(params: SVGParams): String {
        let svg = string::utf8(b"");
        let svg_header = string::utf8(b"<svg width='320' height='320' viewBox='0 0 320 320' xmlns='http://www.w3.org/2000/svg' shape-rendering='crispEdges'>");
        let rect = string::utf8(b"<rect width='100%' height='100%' fill='#");
        let background = params.background;
        let rect_tail =  string::utf8(b"' />");
        let svg_rect = generateSVGRects_(params);
        let svg_tail = string::utf8(b"</svg>");
        string::append(&mut svg, svg_header);
        string::append(&mut svg, rect);
        string::append(&mut svg, background);
        string::append(&mut svg, rect_tail);
        string::append(&mut svg, svg_rect);
        string::append(&mut svg, svg_tail);
        
        return svg
    }

    /**
     * @notice Given RLE image parts and color palettes, generate SVG rects.
     */
    public fun generateSVGRects_(params: SVGParams): String {
        // let lookup = vector[0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320];
        let rects = string::utf8(b"");
        let p = 0;
        let len = vector::length(&params.parts);
        while (p < len) {
            let image = decodeRLEImage_(*vector::borrow(&params.parts, p));
            // let palette = table::borrow(&palettes, image.paletteIndex);
            let currentX = image.bounds.left;
            let currentY = image.bounds.top;
            let cursor = 0;
            let buffer = vector::empty();
            let part = string::utf8(b"");
            let i = 0;
            while (i < len) {
                let rect = *vector::borrow(&image.rects, i);
                if (rect.colorIndex != 0) {
                    vector::insert(&mut buffer, rect.length, cursor);
                    vector::insert(&mut buffer, currentX, cursor + 1);
                    vector::insert(&mut buffer, currentY, cursor + 2);
                    vector::insert(&mut buffer, rect.colorIndex, cursor + 3);
                    cursor = cursor + 4;

                    if (cursor >= 16) {
                        string::append(&mut part, getChunk_(cursor, buffer));
                        cursor = 0;
                    };
                };

                currentX = currentX + rect.length;
                if (currentX == image.bounds.right) {
                    currentX = image.bounds.left;
                    currentY = currentY + 1;
                }
            };

            if (cursor != 0) {
                string::append(&mut part, getChunk_(cursor, buffer));
            };

            string::append(&mut rects, part);
        };

        return rects
    }
    /**
     * @notice Return a string that consists of all rects in the provided `buffer`.
     */
    public fun getChunk_(cursor: u64, buffer: vector<u8>): String {
        let chunk = string::utf8(b"<rec width='");
        let i = 0;
        while (i < cursor) {
            let single_buff = bcs::to_bytes(vector::borrow(&buffer, i));
            let double_buff = bcs::to_bytes(vector::borrow(&buffer, i + 1));
            let triple_buff = bcs::to_bytes(vector::borrow(&buffer, i + 2));
            let quadruple_buff = bcs::to_bytes(vector::borrow(&buffer, i + 3));
            string::append_utf8(&mut chunk, single_buff);
            string::append_utf8(&mut chunk, b"' ");
            string::append_utf8(&mut chunk, b"height='10' x='");
            string::append_utf8(&mut chunk, double_buff);
            string::append_utf8(&mut chunk, b"' ");
            string::append_utf8(&mut chunk, b"y='");
            string::append_utf8(&mut chunk, triple_buff);
            string::append_utf8(&mut chunk, b"' ");
            string::append_utf8(&mut chunk, b"fill='#");
            string::append_utf8(&mut chunk, quadruple_buff);
            string::append_utf8(&mut chunk, b"' ");
            string::append_utf8(&mut chunk, b"/>");
            i = i + 1;
        };
        
        return chunk
    }

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
