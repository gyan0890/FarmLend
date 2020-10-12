//SPDX-License-Identifier: educationwithgyan42@gmail.com
pragma solidity >=0.4.22 <0.7.0;

contract LockLoan {
    
    struct LoanDetails {
        address borrower;
        address lender;
        uint startDate;
        uint startMonth;
        uint startYear;
        uint endDate;
        uint endMonth;
        uint endYear;
        uint amountLocked;
        uint interestRate;
        uint loanLockedTimeStamp;
        mapping(uint => string) assetIds;
    }
    
    constructor() public payable {

    }
    
    mapping(address => LoanDetails) lockedLoans;
    address[] lockedLoanDetails;
    
    function lockLoan(address _borrower, address _lender, uint _endDate, uint _endMonth, uint _endYear,
    uint _amountLocked, uint _interestRate) external payable returns(bool){
        LoanDetails memory loanDetails = lockedLoans[_borrower];
        loanDetails.borrower = _borrower;
        loanDetails.lender = _lender;
        
        //Recording the starting date details
        // loanDetails.startDate = _startDate;
        // loanDetails.startMonth = _startMonth;
        // loanDetails.startYear = _startYear;
        
        //Recording the ending date details
        loanDetails.endDate = _endDate;
        loanDetails.endMonth = _endMonth;
        loanDetails.endYear = _endYear;
        
        loanDetails.amountLocked = _amountLocked;
        loanDetails.interestRate = _interestRate;
        
        lockedLoanDetails.push(_borrower);
        return true;
        
    }
    
    function getNumLockedLoanDetails() public view returns(uint){
        return lockedLoanDetails.length;
    }
    
    function addAssetsToLoan(address _borrower, string memory _assetId, uint version) 
    public returns(string memory){
        LoanDetails storage loanDetails = lockedLoans[_borrower];
        loanDetails.assetIds[version] = _assetId;
        return _assetId;
        
    }
}