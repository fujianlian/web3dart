import 'package:bech32/bech32.dart';
import 'package:hex/hex.dart';

class SegwitAddressUtil {
  static final codec = Bech32Codec();

  /// hrp: address prefix
  /// address: ethereum address
  static String encode(String hrp, String address) {
    var addr = address.replaceFirst('0x', '');
    final addressBytes = HEX.decode(addr);
    String bech32Address =
        codec.encode(Bech32(hrp, convertbits(addressBytes, 8, 5, true)!));
    return bech32Address;
  }

  /// hrp: address prefix
  /// address: bech32 address
  static String? decode(String hrp, String? address) {
    if (address == null) return null;
    Bech32 bech32 = codec.decode(address);
    if (bech32.hrp != hrp || bech32.data.length < 1) return null;
    List<int>? result = convertbits(bech32.data, 5, 8, false);
    if (result == null || result.length < 2 || result.length > 40) return null;
    if (bech32.data[0] == 0 && result.length != 20 && result.length != 32)
      return null;
    final originAddress = HEX.encode(result);
    print('hrp: ${bech32.hrp}, address: $originAddress');
    return originAddress;
  }

  static List<int>? convertbits(
    List<int> data,
    int frombits,
    int tobits,
    bool pad,
  ) {
    int acc = 0;
    int bits = 0;
    List<int> ret = [];
    int maxv = (1 << tobits) - 1;
    for (int p = 0; p < data.length; ++p) {
      int value = data[p];
      if (value < 0 || (value >> frombits) != 0) {
        return null;
      }
      acc = (acc << frombits) | value;
      bits += frombits;
      while (bits >= tobits) {
        bits -= tobits;
        ret.add((acc >> bits) & maxv);
      }
    }
    if (pad) {
      if (bits > 0) {
        ret.add((acc << (tobits - bits)) & maxv);
      }
    } else if (bits >= frombits || ((acc << (tobits - bits)) & maxv) != 0) {
      return null;
    }
    return ret;
  }
}
