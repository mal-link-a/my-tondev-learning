

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "icontroller.sol";

contract controller is icontroller{

    int public health;
    int public armor;

   
    constructor() public {

        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
       
        health=10;  
        armor = 0 ;  
        tvm.accept();     
    }
    function Damage(int value)virtual public override{ //Функция под интерфейс

        health = health-value;
        if (health<=0)
        {           
            killUnit(msg.sender);
        }
        tvm.accept();       
    }
    
    function SetArmor(int value)virtual external { //Броня, еее
        armor = value;
        tvm.accept();
    }
   
    function touch() external {
        tvm.accept();
    }

    function killUnit(address dest) virtual public override{  //Удалить все деньги юнита
        tvm.accept();      
        dest.transfer(10, false, 160);
    }    
}
