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
        
        
        
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))
        if ctx != nil {
            print("Context created")
            
            let sigTxt = "4d54ff3cfb5ee57ebaaba8f4b017b37486bc145b8d48953c56833998dc922e05335e29afa6e6abcf1f580102e2114adbd4b0e8b6b95f899e65c7fb0acef1b6e1"
            let sigArray: [UInt8] = Array(hex: sigTxt)
            var sig = secp256k1_ecdsa_signature()
            let sigRes = secp256k1_ecdsa_signature_parse_compact(ctx!, &sig, sigArray)
            if sigRes == 0 {
                print("Could not parse the signature")
                return
            } else {
                print("Parsed the signature \(sigRes)")
            }
            
            let msgTxt = "'{\"userId\":1,\"direction\":\"north\",\"ordinal\":1\"}'"
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
            guard let pubkeyData = Data(fromHexEncodedString: pubkeyTxt) else { return }
            let pubArray: [CUnsignedChar] = [CUnsignedChar](pubkeyData)
            //let pubArray: [CUnsignedChar] = Array(hex: pubkeyTxt)
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
