pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "SecondAbs.sol";
contract DebotBuy is SecondAbs{

   
 //Ух ты, он внезапно имеет только переопределение меню...
    function _menu() virtual public override{  //Показ дефолтной инфы и кнопок для работы с листом покупок. 
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
}