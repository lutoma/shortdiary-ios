import Foundation
import Sodium
import Clibsodium

private let sodium = Sodium()

enum CryptoError: Error {
    case runtimeError(String)
}

private func deriveKey(password: String, b64Salt: String) -> Bytes? {
    if let salt = sodium.utils.base642bin(b64Salt + "==") {
        return sodium.pwHash.hash(outputLength: Int(crypto_secretbox_keybytes()), passwd: password.bytes, salt: salt, opsLimit: 10, memLimit: 30 * 1024 * 1024)
    }
    return nil
}

func decrypt(key: Bytes, b64Nonce: String, b64CryptData: String) -> Bytes? {
    print("decrypting", key, b64Nonce, b64CryptData)
    if let nonce = sodium.utils.base642bin(b64Nonce), let cryptData = sodium.utils.base642bin(b64CryptData) {
        print("crypt have b64")
        return sodium.secretBox.open(authenticatedCipherText: cryptData, secretKey: key, nonce: nonce)
    }
    print("decrypt could not get b64")
    return nil
}

func cryptoUnlock(password: String, salt: String, masterNonce: String, encryptedMaster: String) -> Bytes? {
    if let ephemeralKey = deriveKey(password: password, b64Salt: salt) {
        return decrypt(key: ephemeralKey, b64Nonce: masterNonce, b64CryptData: encryptedMaster)
    }
    return nil
}
