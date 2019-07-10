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
