pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "controller.sol";
import "unit.sol" as unitsol;

// This is class that describes you smart contract.
contract base is controller{
   address killer;
   address[] public rosterArr;

    constructor() public {   
        health = 200;  
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    function Roster() virtual public {
        rosterArr.push(msg.sender);
        tvm.accept();
    }  
    function killUnit(address value) virtual public override{     
        tvm.accept();       
        value.transfer(10, false, 160);
    }  

    function Damage(int value)virtual public override{
        health = health-value+armor;
        if (health<=0)
        { 
            killer = msg.sender;
            for (uint i=0; i<rosterArr.length;i++)
            {
                  unitsol.unit d = unitsol.unit(rosterArr[i]);                  
                  d.killUnit(killer);
            }      
        killUnit(killer);
        }
        tvm.accept();     
    } 
     function Alive() public returns (bool a)
     {
         a = true;
     }  
}
