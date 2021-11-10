pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "Abstract.sol";

abstract contract SecondAbs is Abstract{   //Согласно заданию, нам выдали работающий проект и сказали написать такой же, только другой. Так что попробуем сделать что-то иное и накосячить
    string temptext; //Переменные для теста 

 function createBuy(uint32 index) public {   // 
        index = index;
        Terminal.input(tvm.functionId(createBuy_), "One line please:", false);
    } 
    function createBuy_(string value) public {        
        temptext =  value;         
        Terminal.input(tvm.functionId(createItem_), "Count please:", false);
    } 
   
    function createItem_(string value) public view{
        (uint256 num,) = stoi(value); //Газ
        //tempuint = num;        
        optional(uint256) pubkey = 0;
        ITodo(m_address).createItem{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(MyStart),
                onErrorId: tvm.functionId(onError)
            }(temptext, num);  // Не забыть заменить обратно в лист
    }  
 function showList(uint32 index) public view { 
        index = index;
        optional(uint256) none;
        ITodo(m_address).getBoys{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showBuys_),
            onErrorId: 0
        }();
    }

    
 function showBuys_( Buy[] buys ) public {  
        uint32 i;
        if (buys.length > 0 ) {
            Terminal.print(0, "Your Item list:");
            for (i = 0; i < buys.length; i++) {
                Buy buy = buys[i];
                string completed;
                if (buy.flagbuy) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"   {} for ${} ", buy.id, completed, buy.text, buy.count,buy.cost));
            }
        } else {
            Terminal.print(0, "Your list is empty");
        }
        _menu();
    }    
function updateBuy(uint32 index) public {
        index = index;
        if (m_buystat.countBuy + m_buystat.countWaiting > 0) {
            Terminal.input(tvm.functionId(updateBuy_), "Enter  number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no Items to update");
            _menu();
        }
    }   
function updateBuy_(string value) public {
        (uint256 num,) = stoi(value);
        m_buyID = uint32(num);
        Terminal.input(tvm.functionId(updateBuy__),"How much money was spent?",false);
    }  
    function updateBuy__(string value) public view {
        (uint temp,) = stoi(value);
        optional(uint256) pubkey = 0;
        ITodo(m_address).MakeItemDone{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(MyStart),
                onErrorId: tvm.functionId(onError)
            }(m_buyID, temp);
    }
 
     function deleteBuy(uint32 index) public {
        index = index;
         if (m_buystat.countBuy + m_buystat.countWaiting > 0) {
            Terminal.input(tvm.functionId(deleteBuy_), "Enter Item number:", false);
        } else {
            Terminal.print(0, "You have no items to delete");
            _menu();
        }
    }
    function deleteBuy_(string value) public view { //```
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        ITodo(m_address).deleteItem{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(MyStart),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
    function _menu() virtual public override;
}