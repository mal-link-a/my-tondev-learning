pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract ItemList{
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

    uint32 m_count; //Кол-во записей, идёт в маппинг
    uint256 m_ownerPubkey; //Ключ владельца
    bool m_ContractFrozen; //Булевое для просто так. Например, запретить все операции, если тру.

    mapping(uint32 => Buy) m_boys; 

    modifier onlyOwner() { 
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

     constructor( uint256 pubkey) public { //Записываем публичный ключ владельца контракта при создании
        require(pubkey != 0, 120);
         
        tvm.accept();
        m_ownerPubkey = pubkey;
        m_ContractFrozen = false;  
    }
function createItem(string text, uint count) external onlyOwner { //Создаем итем
        require(m_ContractFrozen == false, 101);
        tvm.accept();
        m_count++;
        m_boys[m_count] = Buy(m_count, text, count, false, 0);
    }
    function MakeItemDone(uint32 id,uint costa) external onlyOwner { //Сделаем покупку, выставим цену
        require(m_ContractFrozen == false, 101);
        optional(Buy) buy = m_boys.fetch(id);
        tvm.accept();
        Buy thisBuy = buy.get();
        thisBuy.flagbuy = true;
        thisBuy.cost = costa;
        m_boys[id] = thisBuy;
    }
    function deleteItem(uint32 id) external onlyOwner { //Удаляем покупку по Id
        require(m_ContractFrozen == false, 101);
        require(m_boys.exists(id), 102); //Проверка наличия
        tvm.accept();
        delete m_boys[id];
    }
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
     function getStat() public view returns (BuyStat buyStat) {
        uint _countBuy=0; //Всего куплено
        uint _countWaiting=0; //Всего не куплено
        uint _totalCost=0; 

        for((, Buy buy) : m_boys) { 
            if  (buy.flagbuy) {
                _countBuy = _countBuy + buy.count;
                _totalCost = _totalCost + buy.cost;

            } else {
                _countWaiting = _countWaiting + buy.count;
            }
        }
        buyStat = BuyStat( _countBuy, _totalCost,_countWaiting );
    }
    function getFrosenStat() public view returns (bool boo) {
        boo = m_ContractFrozen;
    }
    function Melt() external onlyOwner { //Лочим или делочим контракт
        tvm.accept();     
      m_ContractFrozen != m_ContractFrozen;
    }
} 
