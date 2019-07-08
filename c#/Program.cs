using System;
using System.Text;
using Cryptography.ECDSA;
//using SHA3;
using HashLib;

namespace HelloWorld
{
    class MainClass
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello World2!");
            var message = "Here's a message";
            byte[] msg = Encoding.UTF8.GetBytes(message);
            var seckey = Hex.HexToBytes("c57ca12c10652293ca4fa61f3ee90d6896cf695d7b7891263e2f01cf2fa61cf8");
            var data = Sha256Manager.GetHash(msg);
            //var dataHex = Encoding.UTF8.GetChars(data);
            //Console.WriteLine(dataHex);
            //var sha = new SHA3.SHA3Managed(256);
            //sha.ComputeHash(msg);
            //Console.WriteLine(sha.HashByteLength);
            //var data = Encoding.UTF8.GetBytes(sha.ToString());
            //var data = sha.Hash;
            //var hash = HashFactory.Crypto.SHA3.CreateKeccak256();
            //var res = hash.ComputeString(message, Encoding.UTF8);
            //Console.WriteLine(res);
            //var data = res.GetBytes();
            var recoveryId = 24;
            //var sig = Secp256K1Manager.SignCompressedCompact(data, seckey);
            var sig = Secp256K1Manager.SignCompact(data, seckey, out recoveryId);
            var signature = Hex.ToString(sig);
            Console.WriteLine(signature);
        }
    }
}
