// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
.
.
.

//MADE BY devEMKIDDO 
//check out my github https://github.com/devEmkiddo

*/
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

   
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, defaultRevert);
    }

   
    function functionCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, customRevert);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, defaultRevert);
    }

   
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, defaultRevert);
    }

   
    function functionStaticCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, defaultRevert);
    }

   
    function functionDelegateCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check if target is a contract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                if (target.code.length == 0) {
                    revert AddressEmptyCode(target);
                }
            }
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    
    function verifyCallResult(bool success, bytes memory returndata) internal view returns (bytes memory) {
        return verifyCallResult(success, returndata, defaultRevert);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    /**
     * @dev Default reverting function when no `customRevert` is provided in a function call.
     */
    function defaultRevert() internal pure {
        revert FailedInnerCall();
    }

    function _revert(bytes memory returndata, function() internal view customRevert) private view {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            customRevert();
            revert FailedInnerCall();
        }
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

// MUST SEND ETHER TO THE CONTRACT TO MAKE YOU ELIGIBLE FOR THE AIRDROP, ONCE YOU ARE
//ELIGIBLE YOU CAN NOW GO AHEAD TO CLAIM THE AIRDROP....

contract Airdrop{
    using SafeMath for uint256;
    using Address for address;
    address[] beneficiaries;
    IERC20 public token;
    address payable public owner;
    uint256 public fee = 5000000000000000 wei;
    uint256 public airdropAmount = 2000 *10**9;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public isEligible;

    event TokenAirdropped(
      address indexed to,
       uint256 amount
    );
    event Transfer(
        address indexed from,
         address indexed to,
          uint256 value
          );

    event ChangedOwnership(
        address oldOwner,
        address newOwner
    );
    event Withdrawal(
        address indexed from,
         address indexed to,
          uint256 value
          );

    bool private locked;

    modifier noReentrancy() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token){
       token = IERC20(_token);
       owner = payable(msg.sender);
       isEligible[msg.sender] = true;
       isEligible[address(this)] = true;
    }

    //Must send ether to the contract to be eligigle for the airdrop 

    function claim() external payable{
      require(msg.value >= fee, "Not enough fee");
      require(token.balanceOf(address(this)) >= airdropAmount, "Insufficient contract balance");
      if (isEligible[msg.sender] == true){
          token.transfer(msg.sender, airdropAmount);
      }else {
        revert("Not eligible for this airdrop");
      }
      emit TokenAirdropped(msg.sender, airdropAmount);
      isEligible[msg.sender] = false; //once claimed you cant be eligible until ypu send ether to
      //the contract again..
    }
   
    function _withdrawEther() private  {
      uint256 contractBal = address(this).balance;
      require(contractBal > 0, "Balance must be greater than 0");
      (bool success, ) = payable(msg.sender).call{value: contractBal}("");
      require(success, "Failed to send ether");
    }

    function _withdrawTokens() private {
        uint256 contractBal = token.balanceOf(address(this));
        require(contractBal > 0, "Balance must be greater than 0");
        token.transfer(owner, contractBal);
    }


     function withdrawEther() external onlyOwner noReentrancy{
      _withdrawEther();
      emit Withdrawal(address(this), msg.sender, address(this).balance);
    }

    function withdrawTokens() external onlyOwner{
       _withdrawTokens();
       emit Withdrawal(address(this), msg.sender, token.balanceOf(address(this)));
    }
    
    function burnTokens(uint256 amount) external onlyOwner{
       require(amount > 0, "Balance must be greater than 0");
        token.transfer(burnAddress, amount);
    }

    function changeOwner(address _newOwner) public onlyOwner{
        require(owner != address(0), "Owner cannot be the dead address");
      owner = payable(_newOwner);
      emit ChangedOwnership(msg.sender, _newOwner);
    }

    function eligible() public view returns(address[] memory){
        return beneficiaries;
    }

    function emergencyExit() external onlyOwner{
        _withdrawEther();
        _withdrawTokens();
        delete beneficiaries;
    }
    
    //Getting the balance of both the token & ether

    function tokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function WeiBalance() public view returns(uint256){
        return address(this).balance;
    }

    receive() external payable { 
        beneficiaries.push(msg.sender);
        isEligible[msg.sender] = true;
    }
}

//MADE BY devEMKIDDO 
//check out my github https://github.com/devEmkiddo



