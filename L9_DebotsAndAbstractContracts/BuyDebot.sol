pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "MainDebot.sol";
contract BuDebot is MainDebot{ //is MainDebot{ 

    function start() public override {
        Terminal.input(tvm.functionId(saveUserPublicKey),"Please enter your public key",false);
    }

    function _menu() public override{
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
                MenuItem("Create new item","",tvm.functionId(createBuy)), //createTask
                MenuItem("Show list","",tvm.functionId(showList)),  // showTasks
                MenuItem("Buy","",tvm.functionId(updateBuy))  // updateTask
            ]
        );
    }




}
