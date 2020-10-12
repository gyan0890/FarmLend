//SPDX-License-Identifier: educationwithgyan42@gmail.com
pragma solidity >=0.4.22 <0.7.0;
import "/Users/gyan/Documents/ProjectGyan/BabylonProject/FarmLend/contracts/LockLoan.sol";

contract FarmLend {
    LockLoan lockloan;
    enum LoanState {
        PROPOSAL,
        ACCEPTED,
        LOCKED,
        SUCCESSFUL,
        FAILED
    }
    
    enum PaymentFreq{
        ANNUAL,
        HALFYEARLY,
        SPLITNUM
        
    }
    
    enum LenderState {
        ACTIVE,
        INLOAN,
        INACTIVE
    }
    
    struct Lender {
        address payable lenderAddress;
        LenderState lenderState;
        uint interestOffered;
        uint depositAmount;
        
    }
    
    struct FarmerLoanProposal {
        address payable farmerAddress;
        uint amountRequested;
        uint loanAmountFulfilled; //For now, let's keep it at 100%
        uint maxInterestRate;
        // uint startYear;
        // uint startMonth;
        // uint startDay;
         uint dueDateYear;
        uint dueDateMonth;
        uint dueDateDay;
        uint splitNum; //Number of installments that the loan should disbursed in
        mapping(uint => uint) splitAmountStorage;
        PaymentFreq paymentFreq;
        LoanState loanState;
        //Authentication documents
        
    }
    
    struct Loan {
        FarmerLoanProposal farmerLoanProposal;
        Lender lender;
        LoanState state;
        // uint startYear;
        // uint startMonth;
        // uint startDay;
        uint amountFulfilled;
        uint interestRate;
        uint proposalCount;
        uint collected;
        uint dueDateYear;
        uint dueDateMonth;
        uint dueDateDay;
        //bytes32 mortgage; Right now, we won't use any mortgage concept here
        mapping (uint=>uint) proposal;
    }
    
    constructor() public payable {
        //Dynamically get once deployed on Truffle
        lockloan = LockLoan(0xB117eAA9D7d94CC9E54a85F10c13c8cf34A52781);
    }
    
    mapping(address => FarmerLoanProposal) public registeredProposals;
    address[] public loanProposals;
    
    mapping(address => Lender) public registeredLenders;
    address[] public lenderAccounts;
    
    //Register the farmers with loan requirements
    function registerFarmerLoanProposal(uint _amountRequested, uint _dueDateDay, uint _dueDateMonth, uint _dueDateYear,
    uint _maxInterestRate, uint _splitNum, uint _paymentFreq) public returns(bool){
        FarmerLoanProposal memory farmer  = registeredProposals[msg.sender];
        farmer.farmerAddress = msg.sender;
        farmer.amountRequested = _amountRequested;
        farmer.loanState = LoanState.PROPOSAL;
        
        // farmer.startDay = _startDay;
        // farmer.startMonth = _startMonth;
        // farmer.startYear = _startYear;
        
        farmer.dueDateDay = _dueDateDay;
        farmer.dueDateMonth = _dueDateMonth;
        farmer.dueDateYear = _dueDateYear;
        
        //This will be filled up once the loan is accepted by a Lender.
        farmer.loanAmountFulfilled = 0;
        
        //Check if the farmer has specified any maxInterestRate, else default it to 5%
        if(_maxInterestRate == 0)
            farmer.maxInterestRate = 5;
        else
            farmer.maxInterestRate = _maxInterestRate;
        
        //Check if the farmer has specified any splitNumber, if not assign 
        // 3 as default number of times he would be paid in an year. 
        // This is the frequency in which the farmer would be paid in the year.
        if(_splitNum == 0)
            farmer.splitNum = 2;
        else
            farmer.splitNum = _splitNum;
        
        //This is the payment frequency in which the farmer will return the loan back.
        if(_paymentFreq == 1)
            farmer.paymentFreq = PaymentFreq.ANNUAL;
        else if(_paymentFreq == 2)
            farmer.paymentFreq = PaymentFreq.HALFYEARLY;
        else
            farmer.paymentFreq = PaymentFreq.SPLITNUM;
        
        loanProposals.push(farmer.farmerAddress);
        
        return true;
        
    }
    
    //Register the farmers with loan requirements
    function registerLender(uint _interestRate, uint _depositAmount) public 
    returns(bool){
        Lender memory lender = registeredLenders[msg.sender];
        lender.lenderAddress = msg.sender;
        lender.lenderState = LenderState.ACTIVE;
        
        //This will be entered by the Lender.
        lender.interestOffered = _interestRate;
        
        lender.depositAmount = _depositAmount;
        
        lenderAccounts.push(lender.lenderAddress);
        return true;
    }
    
    //match function: Search for active proposals and match it with active lenders 
    //and share the matched details with the lender - Vinoth - TODO in JS
    event Foundlender(address, uint); 
    //Function approve : Lender to approve the Loan - Gyan
    function approveLoan(address _farmerAddress, bool approval, uint _amount) 
    public {
        
        //Before approval, we need to check if the farmer is in the system
        // We would also be doing the asset creation in the backend before calling this function
        FarmerLoanProposal memory farmer  = registeredProposals[_farmerAddress];
        Lender memory lender = registeredLenders[msg.sender];
	emit Foundlender(msg.sender, lender.depositAmount);
        if(approval == true) {
            farmer.loanState = LoanState.ACCEPTED;
            lender.depositAmount = lender.depositAmount - _amount;
            lender.lenderState = LenderState.INLOAN;
            for(uint i = 0; i < loanProposals.length; i++){
                if(loanProposals[i] == _farmerAddress)
                    delete loanProposals[i];
            }
            //- Create the loan and call the lock contract
            createLoan(_farmerAddress, msg.sender, _amount, 
            lender.interestOffered, farmer.dueDateDay, farmer.dueDateMonth, farmer.dueDateYear); 
        }
        else
            farmer.loanState = LoanState.PROPOSAL;
    }
    
    function createLoan(address _borrower, address _lender, uint _amountRequested, 
            uint _interestRate, uint _dueDateDay, uint _dueDateMonth, 
            uint _dueDateYear) internal returns(bool){
            
            lockloan.lockLoan(_borrower, _lender, _dueDateDay, _dueDateMonth, _dueDateYear,
             _amountRequested,  _interestRate);
    }
    //Get the number of proposals and then get the public mapping to walkthrough ACTIVE ones
    function getNumProposals() public view returns(address[] memory) {
        return loanProposals;
    }


}
