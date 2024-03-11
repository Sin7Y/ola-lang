# CoreLib Functions

## Cryptographic Primitives

The Ola team is progressively adding new cryptographic primitives to the standard library. Reach out for news or if you would be interested in adding more of these calculations in Ola.

### poseidon\_hash

Given an fields (array of fields) or string , returns the resulting poseidon hash.

```solidity
fn poseidon_hash(fields input) -> (hash)
```

example:

```solidity
 string a = "helloworld";
 hash h1 = poseidon_hash(a);
```

### signature

Get the signature of this transaction.

```solidity
  fn signautre_test() -> (fields) {
      return signature();
  }

```

### check\_ecdsa

Verifier for ECDSA Secp256k1 signatures

```solidity
fn check_ecdsa(hash message, fields pk, fields sig)
```

example:

```solidity
fn check_ecdsa_test() {
    hash message = 0x706955c537687b11177b1058f987ecea245a2c0e5d6c0d1ccd3e91db7cbab73ehash;
    fields pubkey = 0xdf31ce59e3db2b1afcfe2618e0bc5907476f6d22971d7cc462da578f3496c623fbd51392f2773b44c5ffcc80acf9b98ae9d809e36d8963eda4765bb77fa716a3fields;
    fields sig = 0x2b87c212f85fc86ec0005cceb9927585e71c3644bb431989713d403cd23800a77cf405c7941c0d53dcb5ae30de730f39759a7fb0f9d7adcfc480f3d3467e31c2fields;
    bool result = check_ecdsa(message, pubkey, sig);
    assert(result);
}
```

## Logging

The standard library provides two familiar statements you can use: `println` and `print`. Despite being a limited implementation of rust's print function , these constructs can be useful for debugging.

example:

```solidity
contract MultInputExample {

    struct Transaction {
        address sender;
        u32 nonce;
        u32 version;
        u32 chainid;
        fields data; 
        fields codes; 
        fields signature;
        hash codeHash; 
    }
    fn foo(Transaction t)  {  
        print(t.sender);
        print(t.nonce);
        print(t.version);
        print(t.chainid);
        print(t.data);
        print(t.codes);
        print(t.signature);
        print(t.codeHash);

    }

}
```

## Assert

ola provides an assertion function, which can ensure the correct execution of some statements. When the assert fails, the transaction will revert.

example:

```solidity
  fn test() {
      u32[] a = new u32[](5);
      u32 b = a.length;
      assert(b == 5);
  }
```

## BlockChain Context

Ola provides many functions to obtain the status of L2 blockchain. The implementation meaning of these functions is mostly consistent with Solidity, but there are differences in writing.

| function name     | Params | Returns                                              | Usage                                    |
| ----------------- | ------ | ---------------------------------------------------- | ---------------------------------------- |
| caller\_address   |        | contract caller address                              | address caller = caller\_address()       |
| origin\_address   |        | contract origin caller address                       | address origin = origin\_address()       |
| code\_address     |        | current execute code contract address                | address code\_addr = code\_address()     |
| current\_address  |        | current state write and read contract address        | address state\_addr = current\_address() |
| chain\_id         |        | (u32) The future may be replaced by u256 data types. | u32 chainID = chain\_id();               |
| block\_number     |        | u32                                                  | u32 blocknumber = block\_number()        |
| block\_timestamp  |        | u32                                                  | u32 time = block\_timestamp()            |
| sequence\_address |        | address                                              | address sequencer = sequence\_address()  |
| tx\_version       |        | u32                                                  | u32 version = tx\_version()              |
| nonce             |        | u32                                                  | u32 nonce\_number = nonce();             |
| tx\_hash          |        | hash                                                 | hash h = tx\_hash()                      |

## Utils

Ola provides some utility functions, here is the list of available functions.

| function name           | Params                                | Returns                   | Usage                                                              |
| ----------------------- | ------------------------------------- | ------------------------- | ------------------------------------------------------------------ |
| u32\_array\_sort        | u32 array                             | sorted array              | u32\_array\_sort(\[2, 1, 3, 4]);                                   |
| get\_selector           |                                       | u32                       | u32 selector = get\_selector("setVars(u32)");                      |
| fields\_concat          | fields a and fields b                 | new fields                | fields ret = fields\_concat(a, b);                                 |
| string\_concat          | string a and string b                 | new string                | string ret = string\_concat(a, b);                                 |
| abi.encode              | various types of uncertain quantities | fields                    | fields encode\_value = abi.encode(a, b);                           |
| abi.decode              | fields data wtih various types        | tuple with all type value | u32 result = abi.decode(data, (u32));                              |
| abi.encodeWithSignature | string function selector and params   | fields                    | fields call\_data = abi.encodeWithSignature("add(u32,u32)", a, b); |
