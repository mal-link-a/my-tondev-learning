pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "unit.sol";
import "icontroller.sol";
// This is class that describes you smart contract.
contract saber is unit {  
  
    constructor() public { 
        armor = 100;
        dmg = 80;     
        require(tvm.pubkey() != 0, 101);      
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    function Damager(icontroller test)virtual public override
    {
        test.Damage(dmg);
        tvm.accept();
    }
  
    function SetDmg(int value) virtual public override {
        dmg = value;
        tvm.accept();
    }
    function SetArmor(int value) virtual public override {
        armor = value;
        tvm.accept();
    }

  
}
