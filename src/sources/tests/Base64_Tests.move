#[test_only]
module suinouns::Base64_est{
    use suinouns::base64::{encode, decode, encode_64, decode_64};
    const ERR_INVALID_LENGTH: u64 = 0;

    fun equal(v1: &vector<u8>, v2: &vector<u8>): bool {
         let n = vector::length(v1);
         let m = vector::length(v2);
         if (n != m) return false;

         let mut i = 0u64;
         while (i < n) {
             let v1 = vector::borrow(v1, i);
             let v2 = vector::borrow(v2, i);
             if (*v1 != *v2)  return false;
             i = i + 1;
         };
         return true
     }

    #[test]
     fun test_16(){
         let bytes = x"0123456789abcdef";
        assert!(vector::length(&bytes) == 8, ERR_INVALID_LENGTH);

        let encoded = encode(bytes);
        assert!(vector::length(&encoded) == 2 * vector::length(&bytes), 0);

        let decoded = decode(encoded);
        assert!(equal(&bytes, &decoded) == true, 0);
     }

    #[test]
    fun test_64(){
        let bytes = b"abdascde";
        assert!(vector::length(&bytes) == 8, ERR_INVALID_LENGTH);

        let encoded = encode_64(bytes);
        let length = ((vector::length(&bytes) + 2) / 3 ) * 4;
        assert!(vector::length(&encoded) == length, 0);

        let decoded = decode_64(encoded);
        assert!(equal(&bytes, &decoded) == true, 0);
    }
}