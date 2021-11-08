pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../L8_Debot/Debot.sol";
import "../L8_Debot/Terminal.sol";
import "../L8_Debot/Menu.sol";
import "../L8_Debot/AddressInput.sol";
import "../L8_Debot/ConfirmInput.sol";
import "../L8_Debot/Upgradable.sol";
import "../L8_Debot/Sdk.sol";

interface ITodo {
   function createBuy(string text, uint count) external;
   function updateBuy(uint32 id,uint costa) external;
   function deleteBuy(int32 id) external;
   function getBoys() external returns (Buy[] boys);
   function getStatBoys() external returns (BuyStat);
}
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


abstract contract Todo is Debot, Upgradable{
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - Item not found
     */
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }
    uint32 m_count;
   
   
    mapping(uint32 => Buy) m_boys; 

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }   

function createBuy(string text, uint count) public onlyOwner {
        tvm.accept();
        m_count++;
        m_boys[m_count] = Buy(m_count, text, count, false, 0);
    }

    function updateBuy(uint32 id,uint costa) public onlyOwner { //Покупаем
        optional(Buy) buy = m_boys.fetch(id);
        require(buy.hasValue(), 102);
        tvm.accept();
        Buy thisBuy = buy.get();
        thisBuy.flagbuy = true;
        thisBuy.cost = costa;
        m_boys[id] = thisBuy;
    }

    function deleteBuy(uint32 id) virtual external onlyOwner {
        require(m_boys.exists(id), 102);
        tvm.accept();
        delete m_boys[id];
    }


    //
    // Get methods
    //

    function getBoys() public view returns (Buy[] buys) {
        string text;
        uint count;
        bool flagbuy;
        uint cost;



        for((uint32 id, Buy buy) : m_boys) {
            text = buy.text;
            count = buy.count;
            flagbuy = buy.flagbuy; 
            cost = buy.cost;         
            buys.push(Buy(id, text, count,flagbuy, cost));
       }
    }
     
}


