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
