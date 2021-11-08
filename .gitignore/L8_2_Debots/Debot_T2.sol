pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Debot_T1.sol";
interface IDebot1 {
   function savePublicKey(string value) external;
   //function savePublicKey(string value) external;
  
}

contract Debot_T2 is Debot_T1 {  

  //  TvmCell public m_todoCode; // TODO contract code
// TvmCell public m_todoData;
  //  TvmCell public m_todoStateInit;
  //  address m_address;  // TODO contract address
   

  //  BuyStat m_buystat;    
  //  uint32 m_taskId;  // Task id for update. I didn't find a way to make this var local
  //  uint32 m_buyID;  
  //  uint256 m_masterPubKey; // User pubkey
  //  address m_msigAddress;  // User wallet address

  //  uint32 INITIAL_BALANCE =  200000000;  // Initial TODO contract balance
  /// @notice Returns Metadata about DeBot.
 function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "TODO DeBot";
        version = "0.1";
        publisher = "malInca";
        key = "Buylist manager";
        author = "malInca";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a modified by anon TODO DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

 
    
    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }    
    function _menu() override public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Purchased/Pending/Total Cost)",                   
                     m_buystat.countBuy, //Всего куплено
                     m_buystat.countWaiting, //Всего не куплено
                     m_buystat.totalCost  // Потрачено на покупки

       
            ),
            sep,
            [
                MenuItem("Create new item","",tvm.functionId(createBuyM)), //createTask
                MenuItem("Show list","",tvm.functionId(showList)),  // showTasks
                MenuItem("Buy","",tvm.functionId(updateBuyM)),  // updateTask
                MenuItem("Delete item","",tvm.functionId(deleteBuyM))  //deleteTask
            ]
        );
    }
    //Создаем покупку
    function createBuyM(uint32 index) public {   // Z
        index = index;
        Terminal.input(tvm.functionId(createBuy_), "One line please:", false);
    } 
    function createBuy_(string value) public {  
        tempText = value; // Z
        Terminal.input(tvm.functionId(createBuy__), "Count please:", false);
    }
    function createBuy__(uint value) public {  
        tempText2 = value; // Z
      createItem_(tempText , tempText2);
    }
   
    function createItem_(string value,uint value2) public view { // Z   
        optional(uint256) pubkey = 0;
        ITodo(m_address).createBuy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(value,value2);  //Протестировать.
    }    
    //Покупаем
    function updateBuyM(uint32 index) public {
        index = index;
        if (m_buystat.countBuy + m_buystat.countWaiting > 0) {
            Terminal.input(tvm.functionId(updateBuy_), "Enter  number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no tasks to update");
            _menu();
        }
    }   
    function updateBuy_(string value) public {
        (uint256 num,) = stoi(value);
        m_buyID = uint32(num);
        ConfirmInput.get(tvm.functionId(updateBuy__),"Is this list completed?");
    }  
    function updateBuy__(uint value) public view {
        optional(uint256) pubkey = 0;
        ITodo(m_address).updateBuy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_buyID, value);
    }
    function deleteBuyM(uint32 index) public {
        index = index;
         if (m_buystat.countBuy + m_buystat.countWaiting > 0) {
            Terminal.input(tvm.functionId(deleteBuy_), "Enter Item number:", false);
        } else {
            Terminal.print(0, "You have items to delete");
            _menu();
        }
    }
   
    function deleteBuy_(string value) public view { //```
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        ITodo(m_address).deleteBuy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
}
