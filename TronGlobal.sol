pragma solidity ^0.4.23;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}

contract TronGlobal {
    
    using SafeMath for uint256;
    
   
   // Struct
    
    struct Player {
        uint Treasurycoins;
        uint Sparecoins;
        uint volatilepoints;
        uint newdeposit;
        uint factories;
        uint countof;
        uint bank; 
        uint dividentpoint;
        uint totalprofitperhour;
    }
    
    
    
    struct Deposit {
        address _addr;
        uint _depoCount;
        uint _depoAmount;
        uint _time;
    }
    
    
    struct Withdraw {
        address _addr;
        uint _withdrawCount;
        uint _withdrawAmount;
        uint _time;
    }
    
    
    struct Buy {
        address _addr;
        uint _buycount;
        uint _type;
        uint _time;
    }
    
    struct Collect {
        address _addr;
        uint _collectcount;
        uint _type;
        uint _profit;
        uint _time;
    }
    
    
    
    // Variables
    uint constant TYPES_FACTORIES = 7; 
    uint[TYPES_FACTORIES] prices = [3500, 17625, 65000, 232500, 705000, 1450000,2500000];
    uint[TYPES_FACTORIES] profit = [5, 24, 92, 336, 1038, 2175, 868];
    address public owner;
    address public contract_add = this;
    
    uint coinval = 25; // Coin Value Per Trx
    uint public deposit_count; // Number of Count in Deposit
    uint public withdraw_count; // Number of Count in Withdraw
    uint public buy_count; // Number of Count in Buy
    uint public collect_count; // Number of Count in Collect
    
    // Public Variables
    uint256 public investedTrx; // Total Amount of  Deposit
    uint256 public withdrawTrx; // Total Amount of  Withdraw
    uint256 public usercount; // Number of  Users
    uint public totalfactories; // Total Number of Factories
    
    uint public contract_bal = address(this).balance;
   
    
    // Mapping Functionalities
    mapping(address => Player) public players;  // Player Details --
    mapping(address => mapping(uint=>Player)) public  fac_count;  // Factory Count For Individual Player with Individual Type 
    mapping(address => bool) public userstatus; // Is User ? 
    mapping(uint => uint) public divident; // Total  Volatile Points  For Individual Type
   
    mapping(address => mapping (uint => Deposit)) public deposit_history; // Deposit Details
    mapping(address => mapping (uint => Withdraw)) public withdraw_history; // Withdraw Details
    mapping(address => mapping (uint => Buy)) public buy_history; // Buy Details
    mapping(address => mapping (uint => Collect)) public collect_history; // Collect Details
    
   mapping(address=>uint) public ind_deposit_count;
   mapping(address=>uint) public ind_withdraw_count;
   mapping(address=>uint) public ind_buy_count;
   mapping(address=>uint) public ind_collect_count;  
   
    

    
    // Constructor 
    
    constructor(address _owner)  payable{
        owner = _owner;
        // contract_add = this;
    }
    
    
    
    // Functions
    function balanceOf(address _add) public view returns(uint){
        return _add.balance;
    }
    
    
   
    function deposit(address _add, uint _time) public payable returns(bool){
        require(_add != owner);
        
        
        uint conversion = (msg.value/1000000);
        uint coinvalue = conversion * coinval;
        
        owner.transfer(msg.value.mul(10).div(100));
        address(this).transfer(msg.value.mul(90).div(100));
        
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(coinvalue);
       
        players[_add].newdeposit = msg.value/1000000;

                if(userstatus[_add]==false)
            {
                userstatus[_add]=true;
                usercount++;
            }
        
        
        investedTrx+=msg.value/1000000;
        
        deposit_count++;
        ind_deposit_count[_add]++;
        
        uint dcount = ind_deposit_count[_add];
        
        deposit_history[_add][dcount]._addr = _add;
        deposit_history[_add][dcount]._depoCount = deposit_count;
        deposit_history[_add][dcount]._depoAmount = msg.value/1000000;
        deposit_history[_add][dcount]._time = _time;
        
        
        
       
        return true;
    }
    
    
    
    function buy(address _add, uint _type, uint _number,uint _volatile,uint _time) public returns(bool) {
        require(_add != owner);
        require(_type < TYPES_FACTORIES && _number > 0);
        //require(players[_add].Treasurycoins>=prices[_type]);
        
        uint total = players[_add].Treasurycoins+players[_add].Sparecoins;
        
        require(total>=prices[_type]);
        
        if(players[_add].Treasurycoins>=prices[_type]){
             players[_add].Treasurycoins-= prices[_type];
        }else if(players[_add].Treasurycoins<prices[_type]){
             prices[_type]-=players[_add].Treasurycoins;
             players[_add].Treasurycoins=0;
             players[_add].Sparecoins-=prices[_type];
        }
        
        fac_count[_add][_type].factories= _type;
        fac_count[_add][_type].countof+=_number;
        fac_count[_add][_type].volatilepoints+= _volatile;
        fac_count[_add][_type].totalprofitperhour+= _number * profit[_type];
        
        players[_add].factories += _number; 
        players[_add].volatilepoints += _volatile;
        
        divident[_type]+=_volatile;
        totalfactories  += _number;
        
       // dividentPoints(_add,_type); //Call Divident Function
        
        buy_count++;
         ind_buy_count[_add]++;
        
        uint bcount = ind_buy_count[_add];
        
        buy_history[_add][bcount]._addr = _add;
        buy_history[_add][bcount]._buycount = buy_count;
        buy_history[_add][bcount]._type = _type;
        buy_history[_add][bcount]._time = _time;
        
        
        uint256 newdeposit = players[_add].newdeposit * coinval;
        uint256 volatil = ((fac_count[_add][_type].countof).mul(newdeposit)).mul(uint256(333).mul((fac_count[_add][_type].volatilepoints).div(divident[_type])));

        players[_add].dividentpoint=volatil;
        return true;
    }
    
    
    
    function collect(address _add,uint _type, uint _time) public  returns(uint256,uint256){
        require(_add != owner);
        
        uint Profit = profit[_type];
        
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(Profit.div(2));
        players[_add].Sparecoins = players[_add].Sparecoins.add(Profit.div(2));
        
        collect_count++;   
        ind_collect_count[_add]++;
        
        uint ccount = ind_collect_count[_add]; 
        
        
        collect_history[_add][ccount]._addr = _add;
        collect_history[_add][ccount]._collectcount = collect_count;
        collect_history[_add][ccount]._type = _type;
        collect_history[_add][ccount]._time = _time;
        collect_history[_add][ccount]._profit = Profit;
        return (players[_add].Treasurycoins.add(Profit.div(2)),players[_add].Sparecoins.add(Profit.div(2))) ; 
    }
    
    
    
    
    function banktotreasury(address _add) public returns(bool){
        players[_add].Treasurycoins+=players[_add].bank;
        players[_add].bank=0;
        return true;
    }
    
    
    
    
    function withdraw(address _add,uint256 coins,uint256 _time,uint256 _amountt) public payable returns(bool){
        require(_add!=msg.sender && players[_add].Sparecoins <0);  
        players[_add].Sparecoins =    players[_add].Sparecoins -coins;
        withdrawTrx+=_amountt/1000000;
        _add.transfer(_amountt);
        
        withdraw_count++;
        ind_withdraw_count[_add]++;
        
        uint wcount  = ind_withdraw_count[_add];
        
        withdraw_history[_add][wcount]._addr = _add;
        withdraw_history[_add][wcount]._withdrawCount = withdraw_count;
        withdraw_history[_add][wcount]._withdrawAmount =  _amountt/1000000;
        withdraw_history[_add][wcount]._time = _time;
	    return true;
    }
    
    
    function dividentPoints(address buyer,address _add,uint256 _type,uint indvolatile,uint totalvolatile) public returns(bool){      //divide the result by 100
        
        uint divi = players[buyer].dividentpoint;
        uint tot = divi.div(100);
        
        uint percentage = (indvolatile.mul(100)).div(totalvolatile);
        
        players[_add].bank+= percentage * tot;
        players[buyer].newdeposit=0;
        players[buyer].dividentpoint-=percentage * tot;
        return true;
    }
  
    
    function dailyprize(address _add) public payable returns(bool){
        if(msg.value>5000 trx && msg.value<25000 trx){
            players[_add].Treasurycoins += 4000;
            return true;
        }else if(msg.value>25000 trx && msg.value<50000 trx){
            players[_add].Treasurycoins += 15000;
            return true;
        }else if(msg.value>50000 trx && msg.value<100000 trx){
            players[_add].Treasurycoins += 30000;
            return true;
        }else if(msg.value>100000 trx){
            players[_add].Treasurycoins += 60000;
            return true;
        }
    }
    
    function timetask(address _add,uint _type) public returns(bool){
       
         if( players[_add].factories>400 &&  players[_add].volatilepoints>25000 && fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==3&& fac_count[_add][_type].countof==1){
            players[_add].Treasurycoins+=1455000;
            return true;
        }else if( players[_add].factories >100 && players[_add].factories<400){
            players[_add].Treasurycoins+=13000;
            return true;
        }else if( players[_add].factories>400){
            players[_add].Treasurycoins+=55000;
            return true;
        }else if(fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==1){
            players[_add].Treasurycoins+=75000;
            return true;
        }else if( players[_add].volatilepoints>1000 &&  players[_add].volatilepoints<25000){
            players[_add].Treasurycoins+=100000;
            return true;
        }else if( players[_add].volatilepoints>25000){
            players[_add].Treasurycoins+=300000;
            return true;
        }else if(fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==3){
            players[_add].Treasurycoins+=250000;
            return true;
        }else{
            return false;
        }
    }
    
    
    
    
    function totalfac(address _add) public view returns(uint){
       require(_add != owner);
        return  players[_add].factories;
    }
    
    
}
