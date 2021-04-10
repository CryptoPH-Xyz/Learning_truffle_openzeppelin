//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;
pragma abicoder v2;
contract MultiSigWallet{
    
    event Deposit(address indexed _from, uint amount, uint balance);
    event proposedTransactions (address _from, address _to, uint amount, uint _txId);
    event signedTransactions (uint _txId, uint _signatures, address _signedBy);
    event confirmedTransactions (uint _txId);
    
    address[] public owners;
    uint public sigRequired;


    struct Transaction {
        address payable to;
        uint amount;
        uint txId;
        bool confirmed;
        uint sigNumber;
    }
    mapping(address => bool) isOwner;
    mapping(address => uint) public balance;
    mapping(uint => mapping(address => bool)) isSigned;

    Transaction[] transactions;

    modifier onlyOwners() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(address[] memory _owners, uint _sigRequired) {
        require(_sigRequired <= _owners.length && _sigRequired > 0 && _sigRequired > (_owners.length / 2), "Number of required signatures must be more than half of Owners"); // In case of multiple owners, require signatures must be > 50% of owners
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
//this will loop around every owner in the owners array ...
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
// ... and require that the owner is not in address 0, and no owner is duplicated
            isOwner[owner] = true;
            owners.push(owner);
        }
        sigRequired = _sigRequired;
    }

    function deposit() public payable {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    
    function getWalletBalance() public view returns(uint) {
        return balance[msg.sender];
    }

    function proposeTransaction(uint _amount, address payable _to) public onlyOwners {
        emit proposedTransactions(msg.sender, _to, _amount, transactions.length);
//bool set to false means: not yet confirmed
//sigNumber set to 0 means: no one has signed yet
        transactions.push(Transaction(_to, _amount, transactions.length, false, 0));
    }
  
    function signTransaction(uint _txId) public onlyOwners {
        require(isSigned[_txId][msg.sender] == false);
// set to false because: msg.sender has not yet signed (if this is true, msg.sender can vote twice)   
        Transaction storage transaction = transactions[_txId];
        transaction.sigNumber ++;
        isSigned[_txId][msg.sender] = true;
        
        emit signedTransactions(_txId, transactions[_txId].sigNumber, msg.sender);
    }
    
    function executeTransaction(uint _txId) public onlyOwners{
        require(transactions[_txId].confirmed == false);
//set to false because: transaction cannot be confirmed yet without the owners' signatures      
        if(transactions[_txId].sigNumber >= sigRequired){
            transactions[_txId].confirmed = true;
            transactions[_txId].to.transfer(transactions[_txId].amount);
            emit confirmedTransactions(_txId);
        }
    }
    
    function getTransaction() public view returns(Transaction[] memory){
        return transactions;
    }
    
    function addOwner(address _newOwner) public {
        require(_newOwner != address(0), "invalid owner");
        require(!isOwner[_newOwner], "owner not unique");
        require(owners.length < 10, "Owner slot full"); // count starts with 0

        isOwner[_newOwner] = true;
        owners.push(_newOwner);
        sigRequired++; // adds 1 to the number of signature required per new owner
/*downside: if we start with 3 owners and 2 sigRequired (needs 67% approval)
            if we add 7 new owners, total owners is 10 and sigRequired would be 9 (90% approval)
            if users reach 100 it would be a (99% approval)
            LIMIT OWNERS to 10
*/
    }
}