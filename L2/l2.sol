
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract l2 {  
    uint32 public alpha = 1;
 
    constructor() public {      
        require(tvm.pubkey() != 0, 101);      
        require(msg.pubkey() == tvm.pubkey(), 102);      
        tvm.accept();       
    }    

    function Fun(uint32 a) public checkOwnerAndAccept returns(uint32){
        require(a  < 11 , 102);
        alpha = (a * alpha);
        return alpha;
    }
    modifier checkOwnerAndAccept {       
        require(msg.pubkey() == tvm.pubkey(), 102);       
        tvm.accept(); 
       _;
    }  
}
