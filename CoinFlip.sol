pragma solidity ^0.8.1;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20CoinFlip is IERC20 {
    string public constant name = "CoinFlip";
    string public constant symbol = "CFL";
    uint8 public constant decimals = 18;
    
    // event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    // event Transfer(address indexed from, address indexed to, uint tokens);
    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_ = 10 ether;
    
    constructor() public{
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
        
    }
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(balances[owner] >= numTokens);
        require(allowed[owner][msg.sender] >= numTokens);
        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
        
    
}

contract DEX {
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    
    IERC20 public token;
    
    constructor() public{
        token = new ERC20CoinFlip();
    }
    function buy() payable public{
        uint256 amountToBuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountToBuy > 0, "You need to send Ether");
        require(amountToBuy <= dexBalance, "Not enough tokens on the DEX");
        token.transfer(msg.sender, amountToBuy);
        emit Bought(amountToBuy);
    }
    function getDexBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Not enough allowed");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
}

contract CoinFlip {
    address payable bank;
    mapping (address => uint) public balances;
    
    // event Sent(address from, address to, uint amount);
    
    constructor() {
        bank = payable(msg.sender);
    }
   
   function getRandom() public view returns(uint){
       uint time = block.timestamp;
       return time % 10;
   }
   
   function getBankBalance() public view returns(uint){
       return bank.balance;
   }
   
   
   function flipCoin() public payable {
    //   require(msg.sender != bank);
    //   require(bank.balance * 10 ** 18 >= amount);
       uint random = getRandom();
       if(random % 2 == 0){
            payable(msg.sender).send(msg.value);
       }
       else{
           bank.transfer(msg.value);
       }
       
       
   }
    
//     function mint(address receiver, uint amount) public{
//         require(msg.sender == minter);
//         balances[receiver] += amount;
//     }
    
//     function send(address receiver, uint amount) public{
//         require(balances[msg.sender] >= amount);
//         balances[msg.sender] -= amount;
//         balances[receiver] += amount;
//         emit Sent(msg.sender, receiver, amount);
//     }
    
//     function getBalance() public view returns (uint){
//         return balances[msg.sender];
//     }
}
