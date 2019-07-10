# Web

For the web we use a [browserified](https://github.com/browserify/browserify) version of our Node implementation. By including pn-crypto.js in your website it will create the PNCrypto object for you with generateKeys, getKeys, and signMessage. As with all other implementations you will need to overwrite the getKeys method with your implementation with respect to how you store your keys. 
