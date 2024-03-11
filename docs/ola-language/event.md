# Event

In Ola, contracts can emit events that signal that changes have occurred. For example, a Ola contract could emit a Deposit event, or BetPlaced in a poker game. These events are stored in the blockchain transaction log, so they become part of the permanent record. From Solidity’s perspective, you can emit events but you cannot access events on the chain.

Once those events are added to the chain, an off-chain application can listen for events. For example, the Web3.js interface has a subscribe() function. 

An event has two parts. First, there is a limited set of topics. Usually there are no more than 3 topics, and each of those has a fixed length of 32 bytes. They are there so that an application listening for events can easily filter for particular types of events, without needing to do any decoding. There is also a data section of variable length bytes, which is ABI encoded. To decode this part, the ABI for the event must be known.

From Ola language perspective, an event has a name, and zero or more fields. The fields can either be `indexed` or not. `indexed` fields are stored as topics, so there can only be a limited number of `indexed` fields. The other fields are stored in the data section of the event. The event name does not need to be unique; just like functions, they can be overloaded as long as the fields are of different types, or the event has a different number of arguments.

The first topic is used to identify the event, this is a hash of the event signature, also known as the selector. If the event is declared `anonymous` then this is omitted, and an additional `indexed` field is available. 

An event can be declared in a contract

```solidity
contract Signer {
  event CounterpartySigned (
      address indexed party,
      address counter_party,
      u32 contract_no
  );
    fn sign(address counter_party, u32 contract_no) {
        emit CounterpartySigned(contract_address(), counter_party, contract_no);
    }
}
```

In the transaction log, the first topic of an event is the poseidon hash of the signature of the event. The signature is the event name, followed by the fields types in a comma separated list in parentheses.  So the first topic for the second UserModified event would be the keccak256 hash of `CounterpartySigned(address,address,u32)`.