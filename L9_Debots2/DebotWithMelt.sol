pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "SecondAbs.sol";
contract DebotWithMelt is SecondAbs{ 
    bool frozen;
    
    function _menu() public override{   //Код при наличии успешного контракта списка покупок
        _menu_(tvm.functionId(finalmenu));
    }

    function _menu_(uint32 value) virtual public {  //Он должен видеть, замороженны ли ффункции контракта, и выводить сообветствующие сообщения
    bool boo;
      optional(uint256) none;
        ITodo(m_address).getFrosenStat{
                abiVer: 2,
                extMsg: true,
                sign: false,
                pubkey: none,
                time: uint64(now),
                expire: 0,
                callbackId: value,
                onErrorId: tvm.functionId(onError)
            }();
    }
   
function finalmenu(bool boo)virtual public{  //Он должен видеть, замороженны ли ффункции контракта, и выводить сообветствующие сообщения    
     optional(uint256) none;
     if (boo == true)
        {
             string sep = '----------------------------------------';
        Menu.select(
            format(
                "YOUR ACCOUNT IS FROSEN. But you have {}/{}/{} (Purchased/Pending/Total Cost)",                   
                     m_buystat.countBuy, //Всего куплено
                     m_buystat.countWaiting, //Всего не куплено
                     m_buystat.totalCost  // Потрачено на покупки
            ),
            sep,
            [
                MenuItem("Show list","",tvm.functionId(showList)),  // Показать список предметов             
                MenuItem("Unfreeze","",tvm.functionId(Melt))  //Удалить из списка
            ]
        );
        }
        else {
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
                MenuItem("Delete item","",tvm.functionId(deleteBuy)),  //Удалить из списка
                MenuItem("Freeze account","",tvm.functionId(Melt))
            ]
        );
        }
    }

    function Melt () public view 
    {
        optional(uint256) pubkey = 0;
        ITodo(m_address).Melt{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(MyStart),
                onErrorId: tvm.functionId(onError)
            }();
    }
}
