pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "MyList.sol";
import "../L9_DebotsAndAbstractContracts/lib/Debot.sol";
import "../L9_DebotsAndAbstractContracts/lib/Terminal.sol";
import "../L9_DebotsAndAbstractContracts/lib/Menu.sol";
import "../L9_DebotsAndAbstractContracts/lib/AddressInput.sol";
import "../L9_DebotsAndAbstractContracts/lib/ConfirmInput.sol";
import "../L9_DebotsAndAbstractContracts/lib/Upgradable.sol";
import "../L9_DebotsAndAbstractContracts/lib/Sdk.sol";
struct Buy {
        uint32 id;
        string text; //Наименование
        uint count;  //Кол-во
        bool flagbuy; //Флаг купленного. По дефу false
        uint cost; //Цена за всё. По дефу 0
    }
struct BuyStat {
        uint countBuy; //Всего куплено
        uint countWaiting; //Всего не куплено
        uint totalCost;  // Потрачено на покупки
}

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}


abstract contract ATodo {
   constructor(uint256 pubkey) public {}
}

interface ITodo {
   function createBuy(string text, uint count) external;
   function updateBuy(uint32 id,uint costa) external;
   function deleteBuy(uint32 id) external;
   function getBoys() external returns (Buy[] boys);
   function getStatBoys() external returns (BuyStat);
}



abstract contract MainDebot is Debot, Upgradable{ 
    bytes m_icon;
    TvmCell public m_todoCode; // TODO contract code
    TvmCell public m_todoData;
    TvmCell public m_todoStateInit;
    address m_address;  // TODO contract address
   

    BuyStat m_buystat;  //Экземпляр структуры 
    uint32 m_taskId;  // Task id for update. I didn't find a way to make this var local
    uint32 m_buyID;  
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address
    string temptext;
    uint tempuint;

    uint32 INITIAL_BALANCE =  200000000;  // Initial TODO contract balance


    function setTodoCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_todoCode = code;
        m_todoData = data;
        m_todoStateInit = tvm.buildStateInit(m_todoCode, m_todoData);
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {   //Код при наличии успешного контракта списка покупок
        _getBuyStat(tvm.functionId(setStat));
    }

   // function start() public override {
  //      Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
  //  }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
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

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function saveUserPublicKey(string value) public {  //Получаем публичный ключ юзера для работы и проверяем наличие списка покупок для него
        (uint res, bool status) = stoi("0x"+value);  
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Boylist ...");
            TvmCell deployState = tvm.insertPubkey(m_todoStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your Boy contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(saveUserPublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }


    function checkStatus(int8 acc_type) public {    //Проверим состояние контракта.  1 - контракт задеплоен и активен, 0 - Готов к деплою, -1 - ещё не задеплоен, 2 - заморожен
        if (acc_type == 1) { 
            _getBuyStat(tvm.functionId(setStat));

        } else if (acc_type == -1)  { 
            Terminal.print(0, "You don't have a Boylist yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) {
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your TODO contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }


    function creditAccount(address value) public {  //Для деплоя контракта. Получаем деньги
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IMsig(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {  // Код циклит метод, если тот выдает ошибку...   
    sdkError;
    exitCode;
        creditAccount(m_msigAddress); 
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfStatusIs0), m_address);
    }

    function checkIfStatusIs0(int8 acc_type) public { //Мы проверяем, загружен ли контракт
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {                                   
            TvmCell image = tvm.insertPubkey(m_todoStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {ATodo, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {  //  
    sdkError;    
    exitCode;
        deploy();
    }

    function setStat(BuyStat buystat) public {
    m_buystat = buystat;   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    _menu();
    }

    function _menu() virtual public {  //Показ дефолтной инфы и кнопок для работы с листом покупок. 
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
                MenuItem("Create new item","",tvm.functionId(createBuy)), //Создать предмет для покупки
                MenuItem("Show list","",tvm.functionId(showList)),  // Показать список предметов
                MenuItem("Buy","",tvm.functionId(updateBuy)),  // Купить предмет
                MenuItem("Delete item","",tvm.functionId(deleteBuy))  //Удалить из списка
            ]
        );
    }
   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~РАБОТА СО СПИСКОМ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     function createBuy(uint32 index) public {   // 
        index = index;
        Terminal.input(tvm.functionId(createBuy_), "One line please:", false);
    } 
    function createBuy_(string value) public {
        
        temptext =  value;         
        Terminal.input(tvm.functionId(createItem_), "Count please:", false);
    } 
   
    function createItem_(string value) public {
        (uint256 num,) = stoi(value);
        tempuint = num;        
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
            }(temptext,tempuint);  // Не забыть протестировать
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
            Terminal.print(0, "Your tasks list:");
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
    
    function _getBuyStat(uint32 answerId) private view {
        optional(uint256) none;
        ITodo(m_address).getStatBoys{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}
