//
//  ViewController.swift
//  Crypto
//
//  Created by Zach Babb on 9/11/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import UIKit
import secp256k1
import CryptoSwift
import JavaScriptCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        
        //verifySignature()
        //signMessage(message: "'{\"userId\":1,\"direction\":\"north\",\"ordinal\":1\"}'")
        signMessage(message: "foo")
        //generateKeys(seedPhrase: "foo bar")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func jsCrypto() {
        var jsSourceContents: String = ""
        if let jsSourcePath = Bundle.main.path(forResource: "bundle", ofType: "js") {
            do {
                // Load its contents to a String variable.
                jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                // Add the Javascript code that currently exists in the jsSourceContents to the Javascript Runtime through the jsContext object.
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let context = JSContext()
        context?.evaluateScript(jsSourceContents)
        
        let window = context?.objectForKeyedSubscript("window")
        let keyGenerator = window?.objectForKeyedSubscript("keyGenerator")
        let generateKeys = keyGenerator?.objectForKeyedSubscript("generateKeys")
        let result = generateKeys?.call(withArguments: ["foo bar"])
        let publicKey = result?.objectForKeyedSubscript("public")
        
        print(window)
        print(keyGenerator)
        print(generateKeys)
        print(result!)
        print(publicKey)
    }
    
    func verifySignature() {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))
        if ctx != nil {
            print("Context created")
            
            //let sigTxt = "4d54ff3cfb5ee57ebaaba8f4b017b37486bc145b8d48953c56833998dc922e05335e29afa6e6abcf1f580102e2114adbd4b0e8b6b95f899e65c7fb0acef1b6e1"
            let sigTxt = "2e0b480c0c013814e979089f587a1839e71a3e708e67b72e014766ff277cf66e5d97908403a345ee44eb3f704e53ce331f1e67671c765c7421a5e49b52e62410"
            let sigArray: [UInt8] = Array(hex: sigTxt)
            var sig = secp256k1_ecdsa_signature()
            let sigRes = secp256k1_ecdsa_signature_parse_compact(ctx!, &sig, sigArray)
            if sigRes == 0 {
                print("Could not parse the signature")
                return
            } else {
                print("Parsed the signature \(sigRes)")
            }
            
            //let msgTxt = "'{\"userId\":1,\"direction\":\"north\",\"ordinal\":1\"}'"
            let msgTxt = "foo"
            print(msgTxt)
            let msgArray: [UInt8] = Array(msgTxt.utf8)
            var msgSHA = SHA3.init(variant: .sha256)
            var msg32: [UInt8]
            do {
              msg32 = try msgSHA.finish(withBytes: msgArray)
            } catch {
                print(error)
                return
            }
            
            let pubkeyTxt = "02e5a5c0c4776cc7e06f0216fb2bdc60740578de62270d08a86e705d6b2ca2b2aa"
            //guard let pubkeyData = Data(fromHexEncodedString: pubkeyTxt) else { return }
            //let pubArray: [CUnsignedChar] = [CUnsignedChar](pubkeyData)
            let pubArray: [CUnsignedChar] = Array(hex: pubkeyTxt)
            //let pubArray: [CUnsignedChar] = Array(pubkeyTxt.utf8)
            var pubkey = secp256k1_pubkey()
            let pubBool = secp256k1_ec_pubkey_parse(ctx!, &pubkey, pubArray, pubArray.count)
            if pubBool == 0 {
                print("Could not parse the public key")
                return
            } else {
                print("Parsed public key")
            }
            
            let sigResult = secp256k1_ecdsa_verify(ctx!, &sig, msg32, &pubkey)
            print("Signature Result:::::")
            print(sigResult)
        } else {
            print("Context creation failed")
        }
    }
    
    func signMessage(message: String) {
        if let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) {
            let msgArray: [UInt8] = Array(message.utf8)
            var msgSHA = SHA3.init(variant: .sha256)
            var msg32: [UInt8]
            do {
              msg32 = try msgSHA.finish(withBytes: msgArray)
            } catch {
                print(error)
                return
            }
            
            let privKeyTxt = "57858f343f6c303376465d6d8addaab6bb7cd498220abcb5794125ce0cf71e89"
            let privKey: [CUnsignedChar] = Array(hex: privKeyTxt)
            
            var sig = secp256k1_ecdsa_signature()
            let sigRes = secp256k1_ecdsa_sign(ctx, &sig, msg32, privKey, nil, nil)
            
            var normalizedSig = secp256k1_ecdsa_signature()
            secp256k1_ecdsa_signature_normalize(ctx, &normalizedSig, &sig)
            //var serialized = [UInt8].init(reserveCapacity: 64)
            var serialized = Data(count: 64)
            guard serialized.withUnsafeMutableBytes({secp256k1_ecdsa_signature_serialize_compact(ctx, $0, &sig) }) == 1 else { return }
            serialized.count = 64
            print(serialized.count)
            print("serialized \(serialized.toHexString())")
            
            var length: size_t = 128
            //var der = [UInt8].init(reserveCapacity: length)
            var der = Data(count: length)
            guard der.withUnsafeMutableBytes({ secp256k1_ecdsa_signature_serialize_der(ctx, $0, &length, &sig) }) == 1 else { return }
            
            der.count = length
            print(der.count)
            print(der.toHexString())
            
            if sigRes == 0 {
                print("Could not make signature")
            } else {
                let signature = stringForSignature(collection: sig.data)
                print(signature)
                let normalizedSignature = stringForSignature(collection: normalizedSig.data)
                print(normalizedSignature)
            }
        }
    }
    
    func generateKeys(seedPhrase: String) {
        var msgArray: [UInt8] = Array(seedPhrase.utf8)
        
        //var msg32: [UInt8]
        for _ in 0..<1 {
            var msgSHA = SHA3.init(variant: .sha256)
            do {
              msgArray = try msgSHA.finish(withBytes: msgArray)
            } catch {
                print(error)
                return
            }
        }
        
        
        if let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) {
            var publicKey = secp256k1_pubkey()
            let pubKeyRes = secp256k1_ec_pubkey_create(ctx, &publicKey, &msgArray)
            
            var length: size_t = 33
            //var der = [UInt8].init(reserveCapacity: length)
            var serialized = Data(count: length)
            guard serialized.withUnsafeMutableBytes({ secp256k1_ec_pubkey_serialize(ctx, $0, &length, &publicKey,  UInt32(SECP256K1_EC_COMPRESSED)) }) == 1 else { return }
            
            print("private key \(msgArray.toHexString())")
            print("publicKey: \(serialized.toHexString())")
        }
    }
    
    func stringForSignature<T>(collection: T) -> String {
        var signature = ""
        let mirror = Mirror(reflecting: collection)
        let tupleElements = mirror.children.map({ $0.value })
        tupleElements.forEach { element in
            signature = signature + String(format: "%02x", element as! UInt8)
        }
        
        return signature
    }
    
    /*func iterate<C,R>(t:C, block:(String,Any)->R) {
        let mirror = reflect(t)
        for i in 0..<mirror.count {
            block(mirror[i].0, mirror[i].1.value)
        }
    }*/

    func bytesConvertToHexString(byte : [UInt8]) -> String {
        var string = ""

        for val in byte {
            //getBytes(&byte, range: NSMakeRange(i, 1))
            string = string + String(format: "%02X", val)
        }

        return string
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Data {

    init?(fromHexEncodedString string: String) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}
