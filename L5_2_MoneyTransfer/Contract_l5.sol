
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// Голый контракт, цель которого - просто существовать. На его адрес будут посылаться "деньги" с wallet_l5
contract Contract_l5 {
      
    constructor() public {
       
        require(tvm.pubkey() != 0, 101);     
        require(msg.pubkey() == tvm.pubkey(), 102);     
        tvm.accept();       
    } 
}
