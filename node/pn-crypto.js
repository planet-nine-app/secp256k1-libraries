const keygen = require('./keygen');
const signer = require('./signer');

module.exports = {
  generateKeys: keygen,
  signMessage: function(message) {
                 let keys = this.getKeys();
                 if(keys && keys.privateKey) {
                   return signer(message, keys.privateKey);
                 }
                 return new Error('Unable to sign message. No keys found');
               },
  getKeys: function() {
     console.warn('You must replace this function with a function that will return ' +
                  'the desired public/private key pair.');
     return null;
  }
};
