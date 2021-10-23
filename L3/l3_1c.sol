
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

//Все методы работают при run-local
contract l3_1c {      
    string[] name  = ["s1","s2"];    
   
    constructor() public {     
        require(tvm.pubkey() != 0, 101);      
        require(msg.pubkey() == tvm.pubkey(), 102);      
        tvm.accept();       
    }

    // Добавляет строку
    // Строка должна быть в двойных кавычках ("str")
    function AddName(string s)public  returns (string[]){

        bool b=false;
        for (uint8 i=0; i < uint8(name.length); i++) //Костыль, потому что не совсем понятно, как удалять инфу в методе MinusOdin()
        {
           if(name[i] == "")
            {
                b = true;
                //name[i] = s;
                break;
            }            
     //   }
        if (b == false)
        {
            name.push(s);    
        }
        return name; 
         }
    }    

    function Minus() public returns(string[]) {        //Выполнение на сервере требует gas/
       if (name.length!=0)
       {
           for (uint8 i=0; i < uint8(name.length-1); i++)
        {
            name[i] = name[i+1];
        }
        delete name [name.length-1]; 
        return name;
       }
        else {         
            return ["OPERATION FAILED"];
        }
    }
    
    modifier checkOwnerAndAccept {       
        require(msg.pubkey() == tvm.pubkey(), 102);       
        tvm.accept(); 
       _;
    }
}