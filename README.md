# Planet Nine Crypto Libraries

Working with cryptography can be intimidating and frustrating. One of the main reasons for this is that there isn't good standardization on how to document and present cryptographic functions. This leads to a lot of esoteric code which can make sense to someone educated in cryptography, but can leave the general populace scratching their heads. At Planet Nine our drive is always to make our platform as easy as possible to implement. A not insignificant task in doing that is to try and present the cryptography we use as easily as possible across all the languages of our platform. That's what this repository is for. 

## Getting Started

Planet Nine uses asymmetric cryptography to sign messages from its clients to its servers. We use the secp256k1 cipher set of the Elliptical Curve Digital Signature Algorithm (ECDSA). This is the same cipher set used by Bitcoin and Ethereum so it has the benefit of being both popular and widely used already. How this all works is beyond the scope of this readme, but essentially it gives us an algorithm where we can generate a public/private keypair. We then use the private key to sign messages, which can then be verified using the public key. 

For you as a client-side implementer, you have four things to worry about: generating keys, sharing the public key with the server, signing messages, and storing keys. Of these four storing keys is far and away most important as you need to protect your private key as much as possible. It's because of this need that Planet Nine leaves storing the keys as an implementation detail as different solutions will require different impelemntations. 

In these libraries, Planet Nine provides libraries that will create an Object/Class which does three things:

`generateKeys(seedPhrase)` - Generates and returns a public/private keypair from a given seed phrase (String)

`getKeys()` - Returns the public/private keypair, implementation is left to the implementer as storage will change

`signMessage(message)` - Returns the signature of the given message. Utilizes `getKeys` and will throw an error if no keys are found

### Generating Keys

For most languages, the hardest part about generating keys is finding a secp256k1 library that "just works". For Node the implementation looks like:

```
const secp256k1 = require('secp256k1');
const sha3 = require('js-sha3');

module.exports = function(seedPhrase) {
  var phraseHash = sha3.sha3_256.create();
  phraseHash.update(seedPhrase);
  var phraseHashBinary = new Buffer(phraseHash.hex(), 'hex');

  let privateKey = phraseHashBinary;

  const publicKey = secp256k1.publicKeyCreate(privateKey);

  return {
    publicKey: publicKey.toString('hex'),
    privateKey: privateKey.toString('hex')
  };
};
```

First we create a hash of the seed phrase. Then we use that hash as the private key of our keypair. Then we calculate the public key of that private key. These keys are highly deterministic and it's easy to see that the same seed phrase will result in the same private key. For this reason implementers need to be [very wary of weak seed phrases](https://www.wired.com/story/blockchain-bandit-ethereum-weak-private-keys/). These HD keys are useful for key recovery, but as Planet Nine has account recovery, it is not recommended to rely on key recovery. 

Please note that this function returns the keypair. If that's undesirable, you can use the same code in a new function that stores the key or otherwise treats it as you'd like. 

### Sending The Public Key To The Server

Planet Nine does not keep a canonical record of third-party implementations. Instead you will be required to send your public key when you want to retrieve a user's information. This means that your public key will need to be made available to the networking layer of your implementation. Public keys are meant to be shared, so you should feel good about this sharing, but if you want to have your public key separate from your private key you will need a different function than the `getKeys` function.

### Signing Messages

Like generating keys, signing messages is also a matter of finding the right secp256k1 library. Here is what signing looks like in Node.

```
const secp256k1 = require('secp256k1');
const sha3 = require('js-sha3');

module.exports = function(message, privateKey) {
  var messageHash = sha3.sha3_256.create();
  messageHash.update(message);
  var messageHashBinary = new Buffer(messageHash.hex(), 'hex');
  var privateKeyBuffer = new Buffer(privateKey, 'hex');

  const signedObject = secp256k1.sign(messageHashBinary, privateKeyBuffer);

  return signedObject.signature.toString('hex');
};
```

Here we take a hash of the message (the signed data must be 32 bytes), then sign it with our private key and return the hexadecimal representation of the result. Not all languages have a suitable sha3 implementation, so the Planet Nine platform also accepts sha256 hashed messages. Check the individual language implementations for which hashing algorithm they use. 

### Storing Keys

Storing private keys is the hard part. Once a private key is compromised as a third party, an attacker can do anything you would have been able to do. The biggest danger for third party implementations is an attacker spending everyone's Power. To help mitigate that you can generate different private keys for each user. Then you'd be storing keys in a database most likely so be sure to encrypt those keys. 

Depending on your platform you might have access to some kind of secure storage. That would be a great place to start. For other platforms (looking at you the web) your options are much more limited and less secure. In all instances your platform's best practices are outside of the scope of this readme, and we don't want to make any recommendations that might compromise someone's implementation. So please do some research to try and find the best scheme for storing your private keys.
