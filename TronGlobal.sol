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
        uint factories;
        uint countof;
        uint bank; 
        uint totalprofitperhour;
    }
    
    
    
    
    // Variables
    uint constant TYPES_FACTORIES = 7; 
    uint[TYPES_FACTORIES] prices = [4375, 17625, 65000, 232500, 705000, 1450000,2500000];
    uint[TYPES_FACTORIES] profit = [6, 24, 92, 336, 1038, 2176, 868];
    address public owner;
    address public manager;
    address public contract_add = this;
    
    uint coinval = 25; // Coin Value Per Trx
    
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

    
    // Constructor 
    
    constructor(address _owner,address _manager)  public {
        owner = _owner;
        manager = _manager;
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
        manager.transfer(msg.value.mul(90).div(100));
        
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(coinvalue);
       
                if(userstatus[_add]==false)
            {
                userstatus[_add]=true;
                usercount++;
            }
        
        
        investedTrx+=(msg.value.mul(90).div(100))/1000000;
        
        return true;
    }
    
    
    
    
    function buy(address _add, uint _type, uint _number,uint _volatile,uint _time) public returns(bool) {
        require(_add != owner);
        require(_type < TYPES_FACTORIES && _number > 0);

        uint total_price = _number.mul(prices[_type]);
        
        uint total_coins = players[_add].Treasurycoins+players[_add].Sparecoins;
        
        require(total_coins >=total_price );
        
        if(players[_add].Treasurycoins>= total_price ){
             players[_add].Treasurycoins-= total_price;
        }else if(players[_add].Treasurycoins< total_price){
           total_price -=players[_add].Treasurycoins;
             players[_add].Treasurycoins=0;
             players[_add].Sparecoins-=total_price;
        }
        
        fac_count[_add][_type].factories= _type;
        fac_count[_add][_type].countof+=_number;
        fac_count[_add][_type].volatilepoints+= _number.mul(_volatile);
        fac_count[_add][_type].totalprofitperhour+=  _number.mul(prices[_type]);
        
        players[_add].factories += _number; 
        players[_add].volatilepoints += _number.mul(_volatile);
        
        divident[_type]+=_number.mul(_volatile);
        totalfactories  += _number;
        
        
        return true;
    }
    
    
    
    function collect(address _add,uint _type, uint _time) public  returns(uint256,uint256){
        require(_add != owner);
        
        uint Profit = profit[_type];
        
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(Profit.div(2));
        players[_add].Sparecoins = players[_add].Sparecoins.add(Profit.div(2));
        
        return (Profit.div(2),Profit.div(2)) ; 
    }
    
    
    
    
    function banktotreasury(address _add) public returns(bool){
        players[_add].Treasurycoins+=players[_add].bank;
        players[_add].bank=0;
        return true;
    }
    
    
    
    
    function withdraw(address _add,uint256 coins,uint256 _time) public payable returns(bool){
        require(manager==msg.sender && players[_add].Sparecoins >= 25);  
        players[_add].Sparecoins =  players[_add].Sparecoins -coins;
        withdrawTrx+=msg.value/1000000;
        _add.transfer(msg.value);
        
	    return true;
    }
    
    
    function dividentPoints(address _add,uint volatil) public returns(bool){      //divide the result by 100
        players[_add].bank+=volatil;
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
        }else if( players[_add].volatilepoints>25000){
            players[_add].Treasurycoins+=300000;
            return true;
        }else if(fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==3){
            players[_add].Treasurycoins+=250000;
            return true;
        }else if( players[_add].volatilepoints>1000 &&  players[_add].volatilepoints<25000){
            players[_add].Treasurycoins+=100000;
            return true;
        }else if(fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==1){
            players[_add].Treasurycoins+=75000;
            return true;
        }else if( players[_add].factories>400){
            players[_add].Treasurycoins+=55000;
            return true;
        }else if( players[_add].factories >100 && players[_add].factories<400){
            players[_add].Treasurycoins+=13000;
            return true;
        }
        else{
            return false;
        }
    }
    
    
    
    
    function totalfac(address _add) public view returns(uint){
       require(_add != owner);
        return  players[_add].factories;
    }
    
    
}
