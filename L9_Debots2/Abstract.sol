pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "ItemList.sol";
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
        uint cost; //Цена за всё. Можно сделать за единицу, но это уже какой-то список для магазина, а не для покупателя выйдет
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
interface ITodo { //Мб,получится это оптимизировать?
   function createItem(string text, uint256 val) external;
   function MakeItemDone(uint32 id,uint costa) external;
   function deleteItem(uint32 id) external;
   function getBoys() external returns (Buy[] boys);
   function getStat() external returns (BuyStat);
   function Melt() external;
   function getFrosenStat() external returns (bool);
}

abstract contract Abstract is Debot, Upgradable{   //Согласно заданию, нам выдали работающий проект и сказали написать такой же, только другой. Так что попробуем сделать что-то иное и накосячить
    bytes m_icon;   
    TvmCell public stateInit;

    address m_address;  // TODO contract address
    BuyStat m_buystat; 
    uint32 m_buyID;  
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address
    



    uint32 INITIAL_BALANCE =  200000000;  // Initial TODO contract balance

     function start() public override {
        Terminal.input(tvm.functionId(OnStart),"Please enter your public key",false);
    }

    function buildStateInit(TvmCell code, TvmCell data) public {  
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();       
        stateInit = tvm.buildStateInit(code, data);
    }     

    function OnStart(string value) public {  //Запуск бота. Получаем публичный ключ юзера для работы и проверяем наличие списка покупок для него
        (uint val, bool status) = stoi("0x"+value);  
        if (status) {
            m_masterPubKey = val;
            Terminal.print(0, "Checking if you already have a list ...");
            TvmCell deployState = tvm.insertPubkey(stateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your List contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(OnStart),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }
    function checkStatus(int8 acc_type) public {    //Проверим состояние контракта.  1 - контракт задеплоен и активен, 0 - залеплоен, -1 - ещё не задеплоен, 2 - заморожен
        if (acc_type == 1) { 
          MyStart(); //Начнём работать с листом
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
    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {  // Код бесконечно циклит метод, если тот выдает ошибку... Это нормальная практика для деботов?   
    sdkError;
    exitCode;
        creditAccount(m_msigAddress); 
    }
    function waitBeforeDeploy() public  { //Просто вызываем проверку.
        Sdk.getAccountType(tvm.functionId(checkNewContractBeforeDeploy), m_address);
    }

    function checkNewContractBeforeDeploy(int8 acc_type) public { //Мы проверяем, загружен ли контракт
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }
     function deploy() private view {  //Деплоим контракт                                 
            TvmCell image = tvm.insertPubkey(stateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(MyStart), 
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
    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {  //Снова циклим метод  
    sdkError;    
    exitCode;
        deploy();
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~АКК ЗАДЕПЛОЕН~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function MyStart() public view {   //Код при наличии успешного контракта списка покупок
        getStatFromContract(tvm.functionId(setStat));
    }
    function getStatFromContract(uint32 value) private view { //Получаем инфу с контракта и передадим её в 
        optional(uint256) none;
        ITodo(m_address).getStat{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: value,
            onErrorId: 0
        }();
    }
    function setStat(BuyStat buystat) public {
    m_buystat = buystat;   
    _menu();
    }
    function _menu() virtual public; //Меню переопределяется деботами

    function onError(uint32 sdkError, uint32 exitCode) public { //Метод ошибок для дочерних контрактов
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        MyStart();
    }
     function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping list";
        version = "0.4";
        publisher = "malInca";
        key = "Buylist manager";
        author = "malInca";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Nya-hello.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }



}
