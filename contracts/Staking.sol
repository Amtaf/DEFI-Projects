//SPDX-License-Identifier: Unlicense
//staking: locking tokens in our contract
//withdraw: Unlock tokens and pull out of the contract
//Claim: Users get reward tokens
//whats a good reward math/mechanism
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking_NeedsMoreThanZero();


contract Staking{
   IERC20 public s_stakingToken;
   IERC20 public s_rewardToken;
   //address to how much has been staked
   mapping(address=>uint256) public s_balances;
   mapping(address=>uint256) public s_rewards;
   //mapping of how much each user has been paid
   mapping(address=>uint256) public s_userRewardPerTokenPaid;
   //how many tokens have been sent to this contract
   uint256 public s_totalSupply;
   uint256 public s_rewardPerTokenStored;
   uint256 public s_lastupdatedTime;
   uint256 public constant rewardRate = 100;

   modifier updateReward(address account){
      //how much reward per token
      //last timestamp
      s_rewardPerTokenStored = rewardPerToken();
      s_lastupdatedTime = block.timestamp;
      s_rewards[account] = earned(account);
      s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
      _;
   }
   modifier moreThanZero(uint256 amount){
      if(amount == 0){
         revert Staking_NeedsMoreThanZero();
      }
      _;
      
   }

   constructor(address stakingToken, address rewardToken){
    s_stakingToken = IERC20(stakingToken);
    s_rewardToken = IERC20(rewardToken);

   }
   function earned(address account) public view returns (uint256) {
      //get current balance
      uint256 currentBalance = s_balances[account];
      //how much they have been paid already
      uint256 userRewardPaid = s_userRewardPerTokenPaid[account];
      uint256 currentRewardPerToken = rewardPerToken();
      uint256 pastRewards = s_rewards[account];

      uint256 earnedd = ((currentBalance * (currentRewardPerToken - userRewardPaid))/1e18) + pastRewards;
      return earnedd;

   }
   function rewardPerToken() public view returns(uint256) {
      if(s_totalSupply == 0){
         return s_rewardPerTokenStored;
      }
      return s_rewardPerTokenStored + (((block.timestamp - s_lastupdatedTime)*rewardRate*1e18)/s_totalSupply);

   }
   function stake(uint256 amount)external updateReward(msg.sender) moreThanZero(amount){
      //keep track of how much user has staked
      s_balances[msg.sender] = s_balances[msg.sender] + amount;
      //keep track of how much user has total
      s_totalSupply = s_totalSupply+amount;
      //transfer tokens to this contract
      bool success = s_stakingToken.transferFrom(msg.sender,address(this), amount);
      //require(success,"Failed");
      if(!success){
         revert Staking__TransferFailed();
      }
      //emit event
   }

   function withdraw(uint256 amount) external updateReward(msg.sender) moreThanZero(amount){
      s_balances[msg.sender] = s_balances[msg.sender] - amount;
      s_totalSupply = s_totalSupply - amount;
      bool success = s_stakingToken.transfer(msg.sender, amount);
      if(!success){
         revert Staking__TransferFailed();
      }
   }

   function claimReward() external updateReward(msg.sender) {
      uint256 reward = s_rewards[msg.sender];
      bool success = s_rewardToken.transfer(msg.sender, reward);
      if(!success){
         revert Staking__TransferFailed();
      }
      //How much rewards theyll get
      //The contract is going to emit x rewards per second
      //and disperse them all them all to stakers

   }

   
}
