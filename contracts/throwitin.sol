//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0; 
//for remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

// for hardhat 
import "hardhat/console.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import "./Base64.sol";
contract FundNFT is ERC721URIStorage {

    // counter starts at 0
    uint private _tokenId;
    string private URI;
// we will take uri from the contract. make sure you have imported ERC721 and ERC721URIStorage from openzeppelin 
    constructor (string memory name, string memory _uri) ERC721(name, "TII") { 
    URI = _uri;
    }
    mapping (address=>bool) contribution;


    function mint(address payable _addressToMint) public { 

         uint newItemId = _tokenId;

        _safeMint(_addressToMint, newItemId);
        
        _setTokenURI(newItemId, URI);

        _tokenId++;  

    }

}


contract throwitin {
using SafeMath for uint256;
address payable owner;
// enum used for defining state of the funding
    enum State {
        Fundraising, // 0 in value
        Expired, // 1 in value
        Successful // 2 in value
    }
 address usdc = address(0x2058A9D7613eEE744279e3856Ef0eAda5FCbaA7e);
 uint maxDeadline; 
 address payable treasury;

constructor(uint maxDeadlineInDays, address payable _treasury, address USDC) {
 maxDeadline = maxDeadlineInDays;     
owner = payable(msg.sender);
treasury = _treasury;
usdc = USDC;
}
struct Project {
    // State variables
    uint databaseID;
    uint  projectId; // id of projects/campaigns (start from 0 )
    address payable  creator; // address of the fund raiser
    string  title; // title of the campaign
    // string  description; // description of the campaign
    uint  amountGoal; // required to reach at least this much, else everyone gets refund
    uint  currentBalance; // the current balance of the project or the fund raised balance 
    uint  deadline; // the deadline till when project should get succesful - (in unix time)
    // string  location; // Location of the creator/ fund raiser
    // string  category; // category of the campaign
    // string img; // the cover img of the campaign (ipfs link)
    string uri; // nft uri that contributors will get
    State  state; // initialize on create with  state = State.Fundraising;
    uint noOfContributors; // total contributors of the campaign / project
    Request[] requests; // total withdrawal requests created by the fund raiser
    uint  numRequests; // Number of requests of withdrawal created by fund raiser
    address NFTaddress;
   }

//   struct Socials {
//       string website;
//       string twitter;
//       string discord;
//       string instagram;
//       string demoVideoLink;
//   } 

struct Request {
        uint requestId; // Id of request created for withdrawal (will start from 0)
        string desc; // Description of the request
        uint value; // the value or amount to withdraw by the campaign creator 
        address payable receipient; // addres to withdrawa the funds
        bool status; // status of withdrawal (false => means not completed) true => means completed the withdrawal
        uint agreeVotes;
        uint disagreeVotes;
        uint requestEndTime;
        State  state;
        
    }


 struct Voters {
       uint requestId;
       mapping (address=>bool) vote; // a mapping to keep track of which address has voted for withdrawal and which haven't
    
    }

 // contributions of particular address as well as record of voted on request, we are saving this seperately
  struct Contributions {
      uint  projectId;
      mapping (address => uint)  contributions;
      Voters[] voters;
 
    }
   Contributions[] arrayContributors;
   

   uint counterProjectID;


   Project[] projects;

  

  // Event that will be emitted whenever funding will be received
    event FundingReceived(uint projectID, uint databaseID, address contributor, uint amount, State state);
    // Event that will be emitted whenever the project request has been fullfilled
    event CreatorPaid(uint projectID, uint databaseID, address recipient);

    event ProjectStarted(uint projectID, uint databaseID, address creatorAddress, string  title, uint  amountGoal, uint  currentBalance, uint  deadline, string uri,State  state, uint noOfContributors, uint  numRequests, address NFTaddress );
    event WithdrawalRequestCreated(uint projectID, uint databaseID, uint RequestID, string desc,  uint value, address receipient,   bool status, uint requestEndTime);
    event ConfirmVote(uint projectID, uint RequestID, uint DatabaseID, address voter);
    event RejectVote(uint projectID, uint RequestID, uint DatabaseID, address voter);

//      // State variables
// uint databaseID;
//     uint  projectId; // id of projects/campaigns (start from 0 )
//     address payable  creator; // address of the fund raiser
//     string  title; // title of the campaign
//     // string  description; // description of the campaign
//     uint  amountGoal; // required to reach at least this much, else everyone gets refund
//     uint  currentBalance; // the current balance of the project or the fund raised balance 
//     uint  deadline; // the     deadline till when project should get succesful - (in unix time)
//     // string  location; // Location of the creator/ fund raiser
//     // string  category; // category of the campaign
//     // string img; // the cover img of the campaign (ipfs link)
//     string uri; // nft uri that contributors will get
//     State  state; // initialize on create with  state = State.Fundraising;
//     uint noOfContributors; // total contributors of the campaign / project
//     Request[] requests; // total withdrawal requests created by the fund raiser
//     uint  numRequests; // Number of requests of withdrawal created by fund raiser
//     address NFTaddress;

function startProject(
        string memory _projectTitle,
        uint _fundRaisingDeadline,
        uint _goalAmount, string memory _uri, uint _databaseID ) public {
        require(maxDeadline>= _fundRaisingDeadline , "deadline should be less than max deadline");

        projects.push(); // we will first push a empty struct  and then fill the detials
        arrayContributors.push(); // we will also push a empty struct of type contributions of anyone for keeping track of contributions of every project

        uint index = projects.length - 1;
       

        projects[index].projectId = counterProjectID; // project id given in increasing order
        projects[index].databaseID = _databaseID; // project id given in increasing order
        
        projects[index].creator = payable(address(msg.sender));
        projects[index].title = _projectTitle;
        // projects[index].description = _projectDesc;
        projects[index].amountGoal = _goalAmount;
        projects[index].deadline = block.timestamp.add(_fundRaisingDeadline.mul(60)); // we need to add the current time in the deadline given as deadline (as deadline given will be difference in current time and end time)
        projects[index].currentBalance = 0;
        // projects[index].location = _location;
        // projects[index].category = _category;
        // projects[index].img = _img;
        projects[index].uri = _uri;
        projects[index].state = State.Fundraising;

        // socials
        // projects[index].links.website = _website;
        // projects[index].links.twitter = _twitter;
        // projects[index].links.discord = _discord;
        
        // we will also assign project id to arraycontributor
      
        arrayContributors[index].projectId = counterProjectID; 

        string memory name = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '"ThrowItIn Project #',
                        counterProjectID,'"}'
                    )
                )
            )
        );
         address nftAddress = address(new FundNFT(name, _uri)); 
         projects[index].NFTaddress = nftAddress;
            //  event ProjectStarted(uint projectID, uint databaseID, address creatorAddress, string  title, uint  amountGoal, uint  currentBalance, uint  deadline, string uri,State  state, uint noOfContributors, uint  numRequests, address NFTaddress );

        emit ProjectStarted(counterProjectID, _databaseID ,msg.sender, _projectTitle, _goalAmount, 0 , projects[index].deadline, _uri,  State.Fundraising, 0, 0, projects[index].NFTaddress );
        counterProjectID++;



        }

       

  /**  Function to change the project state depending on conditions.
      */
    function checkIfFundingCompleteOrExpired(uint _projectId) private {
      // if current balance is more than or equal to the goal, project status should change to succesfull
        if (projects[_projectId].currentBalance >= projects[_projectId].amountGoal) {
            projects[_projectId].state = State.Successful;

           
            
       // if time when this function was called is more than the deadline then project status should change to expired

        
        } else if (block.timestamp > projects[_projectId].deadline)  {
            projects[_projectId].state = State.Expired;
         
          
        }
         // else should remain in fundraising status
        else {
             projects[_projectId].state = State.Fundraising;
           

        }
       
    }


/** Function to fund a project.
      */
// in order to contribute,we will take the projectID to find the project which contributor wants to contribute to , also this function will be of payable type
    function contribute(uint _projectId, uint _amount) external payable returns(bool){

         require(msg.sender != projects[_projectId].creator, "Project creator can't contribute");
          checkIfFundingCompleteOrExpired(_projectId); // check if funding completed or expired or not
          require( projects[_projectId].state == State.Fundraising, "Funding expired or succesful"); 
           IERC20(usdc).transferFrom(msg.sender, address(this), _amount);
      // now we will add the funds to the current balance of this particular project
           projects[_projectId].currentBalance = projects[_projectId].currentBalance.add(_amount);
     // let's add the contribution record of the contributor of this project 
      // let's emit our event     
           emit FundingReceived( _projectId, projects[_projectId].databaseID, msg.sender, _amount, projects[_projectId].state);
      // now will will check if the contributor has already funded once or ist it the first time, if this is the first time we will reward him NFT and also increase the number of Contributor count
         if (arrayContributors[_projectId].contributions[msg.sender] == 0) {
         projects[_projectId].noOfContributors++;
        // we will write the FundNFT contract in the end, but here we will have to pass the address of the contributor and the URI of the NFT to reward for contributing
        // new FundNFT( payable (address (msg.sender)), "https://gateway.pinata.cloud/ipfs/QmUa2KQr7xmuFA9VCMLKbGFDBGwXnEroHxoFNVahs49HtQ"); 
         
           // we are revoking this function so if after this contribution if the state changes it will update that
        }
         else {
         
          // we are revoking this function so if after this contribution if the state changes it will update that

         }
          checkIfFundingCompleteOrExpired(_projectId);
          emit FundingReceived( _projectId, projects[_projectId].databaseID, msg.sender, _amount, projects[_projectId].state);
        arrayContributors[_projectId].contributions[msg.sender] = arrayContributors[_projectId].contributions[msg.sender].add(_amount);
        return true;

    }


/** Function to refund donated amount when a project expires.
      */
    function getRefund(uint _projectId) public returns (bool) {
     // first of all we will check if the project is expired or not  
         checkIfFundingCompleteOrExpired(_projectId);
     // project should be in expired state in order for contributors to get their refund
        require( projects[_projectId].state == State.Expired , "project not expired, can't refund");
        require(arrayContributors[_projectId].contributions[msg.sender] > 0, "you have not contributed to this project");
      


        uint amountToRefund = arrayContributors[_projectId].contributions[msg.sender];
     // let's make contribution of msg.sender to 0 
       arrayContributors[_projectId].contributions[msg.sender] = 0;
        //  address payable sender = payable(msg.sender);
         IERC20(usdc).approve(msg.sender, amountToRefund);
    if (!IERC20(usdc).transferFrom(address(this), msg.sender, amountToRefund)) {
     // if the .send returns false, this will be again restore the amount in the contribution of msg.sender
           arrayContributors[_projectId].contributions[msg.sender] = amountToRefund;
            return false;
        } else {
      // if the transaction of .send is successful, it will run this - reducing the current balance of the campaign
            projects[_projectId].currentBalance = projects[_projectId].currentBalance.sub(amountToRefund);
        }
         return true;
    }



function getDetails(uint _projectId) public view returns (Project memory) {
    return projects[_projectId];
  
    }



// function to create request for payout of certain amout of money for some requirement

    function createRequest( uint _projectId, string memory _desc, uint _value, address payable _receipient) public  {
// we will check if the project is successful or not. Also only creator can create a withdrawal request
        require( projects[_projectId].state == State.Successful, "project expired or successful can't create request");
        require(msg.sender == projects[_projectId].creator, "only manager can create Request");
        require(_value <= projects[_projectId].currentBalance, "withdrawal is more than balance");

// we will push a empty struct of Request type in project  
        projects[_projectId].requests.push();
// we will push a empty strcut of Voters Struct type in voters to keep track of who voted and who haven't
        arrayContributors[_projectId].voters.push();
// we will create num for id/index
        uint num = projects[_projectId].requests.length - 1;

      // assign values to request that we pushed in the project   

         projects[_projectId].requests[num].desc = _desc;
         projects[_projectId].requests[num].value = _value;
         projects[_projectId].requests[num].receipient = _receipient;
         projects[_projectId].requests[num].requestId = num;
         projects[_projectId].requests[num].state = State.Fundraising;
         projects[_projectId].requests[num].requestEndTime = 7*24*3600 + block.timestamp;
     // we will now increment number of request (numRequest)
        //  event WithdrawalRequestCreated(uint projectID, uint databaseID, uint RequestID, string desc,  uint value, address receipient,   bool status, uint requestEndTime);

        emit WithdrawalRequestCreated(_projectId, projects[_projectId].databaseID, num , _desc, _value, _receipient, false, projects[_projectId].requests[num].requestEndTime);

    }



// function to send payout to particular address if the vote is won by creator (private function)

    function sendPayout (uint _projectId, address payable _address, uint _value, uint _requestNo) private  returns(bool) {
         Request storage thisRequest = projects[_projectId].requests[_requestNo]; 
         require(thisRequest.agreeVotes >= thisRequest.disagreeVotes, "condition not fullfilled yet");
        // _address.transfer(_value);
        uint amountToTransfer = _value*97/100;
        uint fee = _value*2/100; // we will take 2% fee on withdrawal 
         IERC20(usdc).approve(msg.sender, _value);
    if (IERC20(usdc).transferFrom(address(this), msg.sender, amountToTransfer)) {
            IERC20(usdc).approve(treasury, fee);
            IERC20(usdc).transferFrom(address(this), treasury, fee);
            projects[_projectId].currentBalance = projects[_projectId].currentBalance.sub(_value);
            emit CreatorPaid(_projectId,_requestNo, _address);
            
            return (true);
        } else {
             return (false);
        }

        
    }


    function claimNFT(uint _projectID) public {
       require( projects[_projectID].state == State.Successful, "project not succesfull yet");
    require(arrayContributors[_projectID].contributions[msg.sender] > 0, "you must be a contributor to vote");
      

        FundNFT(projects[_projectID].NFTaddress).mint(payable(msg.sender));

    
    }



 // function to add vote to particular request 
    function voteRequest(uint _projectId, uint _requestNo, bool vote) public {

      
   
        require( projects[_projectId].state == State.Successful, "project expired or successful can't create request");
        require(arrayContributors[_projectId].contributions[msg.sender] > 0, "you must be a contributor to vote");
        // require(array);
       
        
     // checking if the voter has already voted or not
        require ( arrayContributors[_projectId].voters[_requestNo].vote[msg.sender] == false, "you have already voted");
        // require(  )
        
    uint contri = arrayContributors[_projectId].contributions[msg.sender];
    uint callersVote;
    if(contri <= 1000000*10 && contri >=  0 ) {
        callersVote = 1;
    }
    else if( contri <= 1000000*100 && contri >=  1000000*10){
       callersVote = 1;
    }
    else if( contri <= 1000000*1000 && contri >= 1000000*100){
       callersVote = 2;
    }
    else if( contri <= 1000000*10000 && contri >= 1000000*1000){
       callersVote = 3;
    }
 
    else if( contri <= 1000000*100000 && contri >= 1000000*10000){
       callersVote = 5;
    }
    else if( contri <= 1000000*1000000 && contri >= 1000000*100000){
       callersVote = 8;
    }
    else if( contri >= 1000000*1000000){
       callersVote = 10;
    }
 
     // increament number of voter
     if(vote == true) {
        projects[_projectId].requests[_requestNo].agreeVotes += callersVote;
     }
     else if (vote == false) {
         projects[_projectId].requests[_requestNo].disagreeVotes += callersVote; 
     }
      // mark vote of msg.sender to true
      arrayContributors[_projectId].voters[_requestNo].vote[msg.sender] = true;
      // check if voting won or not, if won do the payout and change the done status to true

        if(projects[_projectId].requests[_requestNo].agreeVotes >= projects[_projectId].requests[_requestNo].disagreeVotes && projects[_projectId].requests[_requestNo].requestEndTime <= block.timestamp) {
        projects[_projectId].requests[_requestNo].status = true;
        projects[_projectId].requests[_requestNo].state = State.Successful;
        emit ConfirmVote(_projectId, _requestNo,  projects[_projectId].databaseID,  msg.sender);

        sendPayout(_projectId, projects[_projectId].requests[_requestNo].receipient, projects[_projectId].requests[_requestNo].value, _requestNo);    
        }
        else if(projects[_projectId].requests[_requestNo].disagreeVotes >= projects[_projectId].requests[_requestNo].agreeVotes && projects[_projectId].requests[_requestNo].requestEndTime <= block.timestamp) {
        projects[_projectId].requests[_requestNo].status = false;
        projects[_projectId].requests[_requestNo].state = State.Expired;

        emit RejectVote(_projectId, _requestNo,  projects[_projectId].databaseID,  msg.sender);
        }
        
    }


   function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getAllProjects() public view returns (Project[] memory) {
     return projects;
           
    }

    function myContributions(uint _projectId, address _address) public view returns (uint) {
      return arrayContributors[_projectId].contributions[_address];
    }
     
    function getAllRequests(uint _projectID) public view returns (Request[] memory) {
    return projects[_projectID].requests;
    }


   
}