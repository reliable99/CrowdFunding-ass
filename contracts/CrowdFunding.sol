 // SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.27;


contract CrowdFunding {
    address public  creator;
    uint256 public goal;
    uint256 public deadline;

    mapping  (address => uint256) public  contributions;

    uint256 public totalContributions;

    bool public isFunded;

    bool public isCompleted;

    event GoalReached(uint256 totalContributions);
    event FundTransfer(address backer, uint256 amount);
    event DeadLineReached(uint256 totalContributions);


    constructor (uint256 fundingGoalInEther, uint256 durationInMinutes){
        creator = msg.sender;
        goal = fundingGoalInEther * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        isFunded = false;
        isCompleted = false;

    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can call this function.");
        _;
    }

    function contribute () public payable {
        require(block.timestamp < deadline, "Funding period has ended.");
        require(!isCompleted, "CrowdFunding is already completed. ");

        uint256 contribution = msg.value;
        contributions[msg.sender] += contribution;
        totalContributions += contribution;


        if (totalContributions >= goal ){
            isFunded = true;
            emit GoalReached(totalContributions);
        }

        emit FundTransfer(msg.sender, contribution);

    }
        function withdrawFunds() public onlyCreator{
            require(isFunded, "Goal has not been reached.");
            require(!isCompleted, "CrowdFunding is already completed.");

            isCompleted = true;
            payable (creator).transfer(address(this).balance);
        }

        function getRefund () public {
            require(block.timestamp >= deadline, "Funding period has not ended");
            require(!isFunded, "Goal has been reached");
            require(contributions[msg.sender] > 0, "No contribution to resfund");

            uint256 contribution = contributions[msg.sender];
            contributions [msg.sender] = 0;
            totalContributions -= contribution;
            payable (msg.sender). transfer(contribution);
            emit FundTransfer(msg.sender, contribution);
        }
    
        function getCurrentBalance () public view  returns (uint256){
            return address(this).balance;
        }

        function extendDeadline (uint256 durationInMinutes) public onlyCreator{
            deadline += durationInMinutes * 1 minutes;
        }

}