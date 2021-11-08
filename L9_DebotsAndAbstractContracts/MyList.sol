pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract MyList{
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

    uint32 m_count;
    uint256 m_ownerPubkey; 
    mapping(uint32 => Buy) m_boys; 

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }
     constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

function createBuy(string text, uint count) public onlyOwner { //Создаем итем
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

    function deleteBuy(uint32 id) virtual external onlyOwner { //Удаляем покупку по Id
        require(m_boys.exists(id), 102);
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
     function getStatBoys() public view returns (BuyStat buyStat) {
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
} 
