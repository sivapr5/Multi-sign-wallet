pragma solidity ^0.5.1;

/// @title 2 of 3 Multisig Wallet for use with Strato
contract multisig {

// we are adding 3 oweners for approving transaction 
 address payable public _owner;
address payable public _owner2;
address payable public _owner3;

constructor () public payable{
_owner=0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
 _owner2=0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
_owner3=0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
}

//properties
uint public _transactionIdx;

//minimum of 2 signatures (this is modifiable)
uint constant minimum_sigs = 3;

modifier isOwner() {
require (msg.sender == _owner);
_;
}

modifier approvedSigner() {
require (msg.sender == _owner || msg.sender == _owner2 || msg.sender == _owner3,"transaction not signed");
_;
}

//constructor
struct Transaction {
address from;
address payable to;
uint amount;
//how many people have signed?
uint8 signatureCount;
//who has signed?
mapping(address => uint8) signatures;
string name;
}

//events
event DepositFunds(address payable from, uint amount);
event TransactionCreated(address from, address to, uint amount, uint transactionId);
event TransactionCompleted(address from, address to, uint amount, uint transactionId);
event TransactionSigned(address by, uint transactionId);

//mappings
mapping (uint => Transaction) public _transactions;
uint[] private _pendingTransactions;

//functions
function InitMultisigWallet()
public {
_owner = msg.sender;
}

//deposit funds to multisig contract and log as an event
function depositToWallet() public payable {
emit DepositFunds(msg.sender, msg.value);
}
uint public transid;
//transfer funds from multisig contract to another address



function transferTo(address payable _to, uint _amount,string memory _name) approvedSigner public {
//check to ensure not overspending
require(address(this).balance >= _amount,"not sufficient");
uint transactionId = _transactionIdx++;
transid=_transactionIdx;
Transaction storage transaction = _transactions[transactionId];
_transactions[transactionId].from=msg.sender;
transaction.from = msg.sender;
transaction.to= _to;
transaction.amount = _amount;
transaction.signatureCount = 0;
_transactions[transactionId].name=_name;
//define where transaction exists in data structure
_transactions[transactionId] = transaction;
_pendingTransactions.push(transactionId);
//emit event for frontend
emit TransactionCreated(msg.sender, _to, _amount, transactionId);
}



uint public checktrans;







uint public signersfees;


function signTransaction(uint transactionId) approvedSigner public payable {
Transaction storage transaction = _transactions[transactionId];
// Make sure that the transaction exists


//The initiator does not count as a signee
// require(msg.sender != transaction.from);
// Cannot sign a transaction more than once
require(transaction.signatures[msg.sender] != 1,"already signed");
transaction.signatures[msg.sender] = 1;
transaction.signatureCount++;
//emit the details of who signed it
emit TransactionSigned(msg.sender, transactionId);

if (transaction.signatureCount >= minimum_sigs) {
   
   
require(address(this).balance >= transaction.amount,"insufficient balance");

signersfees=transaction.amount/10;

uint owner1fee=signersfees/3;
uint ownerfees2=signersfees/3;
uint ownerfees3=signersfees/3;





uint finalamount=transaction.amount-signersfees;



_owner.transfer(owner1fee);
_owner2.transfer(ownerfees2);
_owner3.transfer(ownerfees3);
transaction.to.transfer(finalamount);
emit  TransactionCompleted(transaction.from,transaction.to, transaction.amount, transactionId);
}

 }

function walletBalance() public view returns (uint) {
return address(this).balance;
}
}
