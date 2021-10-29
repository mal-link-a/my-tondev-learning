
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "base.sol" as basesol;
import "controller.sol";
import "icontroller.sol";


contract unit is controller 
{
   address public mybase;  
    int public dmg;
    constructor() public { 
        require(tvm.pubkey() != 0, 101);    
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

    } 

    function SetBase(address test)virtual public 
    {
        mybase = test;
        basesol.base d = basesol.base(test);
        d.Roster();
        tvm.accept();
    }

    function Damager(icontroller tessst)virtual public
    {
        tessst.Damage(dmg);
        tvm.accept();
    }
    function Killer(icontroller tesst, address adr)virtual public
    {
        tesst.killUnit(adr);
        tvm.accept();
    }
    function Damage(int value)virtual public override{
        health = health-value+armor;
        if (health<=0)
        {           
            killUnit(msg.sender);
        }
        tvm.accept();     
    }
    function SetArmor(int value) virtual public override {
        armor = value;
        tvm.accept();
    }    
    function SetDmg(int value) virtual public {
        dmg = value;
        tvm.accept();
    }
    function killUnit(address dest) virtual public override{
        tvm.accept();      
        dest.transfer(10, false, 160);
    }  
    
}
