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
    
    uint constant TYPES_FACTORIES = 7; 
    uint[TYPES_FACTORIES] prices = [3750, 17625, 66750, 232500, 705000, 1455000,2500000];
    uint[TYPES_FACTORIES] profit = [5, 24, 95, 336, 1038, 2183, 868];
    address owner;
    address manager;
    
    struct Player {
        uint Treasurycoins;
        uint Sparecoins;
        uint volatilepoints;
        uint newdeposit;
        uint factories;
        uint countof;
        uint bank; 
    }
    
    uint deposit_count;
    uint withdraw_count;
    uint eventvalue =1;
    uint256 public investedTrx;
    uint256 public withdrawTrx;
    mapping(address => bool) public userstatus;
    uint256 public usercount;
    uint public totalfactories;
    uint coinval = 25;
    uint256 public volatile;
    mapping(address => Player) public players;
    mapping(address => mapping(uint=>Player)) fac_count; 
    mapping(address => uint) public balance;
    mapping(address => uint) public numberof_fac;

    mapping(uint => uint) public divident;
    mapping(address => uint) public numberof_volatile;
    
    event depositevent(address addr,uint trxval,uint depo_count);
    event withdrawevent(address addr,uint trxval,uint depo_count);

    event buyevent(address addr, uint _type,uint time,uint value);
    
    constructor(address _owner, address _manager) public {
        owner = _owner;
        manager = _manager;
    }
    
    function balanceOf(address _add) public view returns(uint){
        return _add.balance;
    }

    function deposit(address _add) public payable returns(bool){
        require(_add != owner && (_add != manager));
        require(msg.value!=0);
        uint conversion = (msg.value/1000000);
        uint coinvalue = conversion * coinval;
        owner.transfer(msg.value.mul(10).div(100));
        manager.transfer(msg.value.mul(90).div(100));
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(coinvalue);
       
        players[_add].newdeposit = msg.value/1000000;

                if(userstatus[_add]==false)
            {
                userstatus[_add]=true;
                usercount++;
            }
        
        
        investedTrx+=msg.value/1000000;
        deposit_count++;
        emit depositevent(_add,msg.value/1000000,deposit_count);
        return true;
    }
    
    function buy(address _add, uint _type, uint _number,uint _volatile,uint _time) public returns(bool) {
        require(_add != owner && (_add != manager));
        require(_type < TYPES_FACTORIES && _number > 0);
        require(players[_add].Treasurycoins>=prices[_type]);
        players[_add].Treasurycoins-= prices[_type];
        fac_count[_add][_type].factories= _type;
        fac_count[_add][_type].countof+=_number;
        fac_count[_add][_type].volatilepoints+= _volatile;
        numberof_fac[_add]+=_number;
        numberof_volatile[_add]+=_volatile;
        divident[_type]+=_volatile;
        totalfactories  += _number;
        dividentPoints(_add,_type);
        emit buyevent(_add,_type,_time,eventvalue);
        eventvalue++;
        return true;
    }
    
    function collect(address _add,uint _type) public  returns(bool){
        require(_add != owner && (_add != manager));
        
        uint Profit = profit[_type];
        
        players[_add].Treasurycoins = players[_add].Treasurycoins.add(Profit.div(2));
        players[_add].Sparecoins = players[_add].Sparecoins.add(Profit.div(2));
        return true; 
    }
    
    function banktotreasury(address _add) public returns(bool){
        players[_add].Treasurycoins+=players[_add].bank;
        players[_add].bank=0;
        return true;
    }
    
    function withdraw(address _add) public payable returns(bool){
        require(_add != owner && (_add != manager));
        require(players[_add].Sparecoins>=25);
        players[_add].Sparecoins-= msg.value/1000000;
        withdrawTrx+=msg.value/1000000;
        _add.transfer(msg.value);
        withdraw_count++;
        emit withdrawevent(_add,msg.value/1000000,withdraw_count);
	return true;
    }
    
    
    function dividentPoints(address _add,uint _type) public returns(bool){      //divide the result by 100
        uint256 newdeposit = players[_add].newdeposit * coinval;
        uint256 volatil = ((fac_count[_add][_type].countof).mul(newdeposit)).mul(uint256(333).mul((fac_count[_add][_type].volatilepoints).div(divident[_type])));
        players[_add].bank+=volatil.div(100);
        players[_add].newdeposit=0;
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
        if(numberof_fac[_add]>400&&numberof_volatile[_add]>25000&&fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==3&& fac_count[_add][_type].countof==1){
            players[_add].Treasurycoins+=1455000;
            return true;
        }else if(numberof_fac[_add]>100 && numberof_fac[_add]<400){
            players[_add].Treasurycoins+=13000;
            return true;
        }else if(numberof_fac[_add]>400){
            players[_add].Treasurycoins+=55000;
            return true;
        }else if(fac_count[_add][_type].factories==6 && fac_count[_add][_type].countof==1){
            players[_add].Treasurycoins+=75000;
            return true;
        }else if(numberof_volatile[_add]>1000 && numberof_volatile[_add]<25000){
            players[_add].Treasurycoins+=100000;
            return true;
        }else if(numberof_volatile[_add]>25000){
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
        require(address(_add)!=address(0));
        return numberof_fac[_add];
    }
    
    
}
