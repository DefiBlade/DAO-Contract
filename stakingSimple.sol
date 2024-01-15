pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract StakingContract is ReentrancyGuard, Ownable {
    bool public CONTRACT_RENOUNCED = false; // for ownerOnly Functions

    string private constant NEVER_CONTRIBUTED_ERROR =
        "This address has never contributed Tokens to the protocol";
    string private constant NO_ETH_CONTRIBUTIONS_ERROR =
        "No Token Contributions";
    string private constant MINIMUM_CONTRIBUTION_ERROR =
        "Contributions must be over the minimum contribution amount";

    IERC20 public token;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastStakeTime;
    address[] public stakerList;

    uint256 public stakingPeriod = 30 * 24 * 60 * 60; // 30 days
    uint256 public rewardRate = 1000; // 1000 tokens per staking period
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    receive() external payable {}

    fallback() external payable {}

    constructor(address _token) {
        token = IERC20(_token);
        lastUpdateTime = block.timestamp;
    }

    function RenounceContract() external onlyOwner {
        CONTRACT_RENOUNCED = true;
    }

    function getRewards() external {
        uint256 reward = earned(msg.sender);
        require(reward > 0, "Cannot get 0 reward tokens");
        token.transfer(msg.sender, reward);
        lastStakeTime[msg.sender] = block.timestamp;
        lastUpdateTime = block.timestamp;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Cannot stake 0 tokens");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        if (stakedAmount[msg.sender] > 0) {
            uint256 reward = earned(msg.sender);
            if (reward > 0) {
                token.transfer(msg.sender, reward);
            }
        } else {
            stakerList.push(msg.sender);
        }

        stakedAmount[msg.sender] += amount;
        lastStakeTime[msg.sender] = block.timestamp;
        lastUpdateTime = block.timestamp;
    }

    function unstake() public {
        require(stakedAmount[msg.sender] > 0, "Nothing staked");
        _unstake(msg.sender);
    }

    function _unstake(address account) private {
        require(stakedAmount[account] > 0, "Nothing staked");

        uint256 reward = earned(account);
        if (reward > 0) {
            token.transfer(account, reward);
        }

        uint256 amount = stakedAmount[account];
        stakedAmount[account] = 0;
        lastStakeTime[account] = 0;
        lastUpdateTime = block.timestamp;

        require(token.transfer(account, amount), "Transfer failed");
    }

    function earned(address account) public view returns (uint256) {
        uint256 stakedTime = block.timestamp - lastStakeTime[account];
        uint256 totalStaked = token.balanceOf(address(this));
        uint256 rTokens = rewardPerToken();

        return
            (stakedAmount[account] * (rTokens - rewardPerTokenStored)) /
            1e18 +
            (stakedTime * rewardRate * 1e18) /
            stakingPeriod /
            totalStaked;
    }

    function rewardPerToken() public view returns (uint256) {
        if (token.balanceOf(address(this)) == 0) {
            return rewardPerTokenStored;
        }

        uint256 lastElapsed = block.timestamp - lastUpdateTime;
        return
            rewardPerTokenStored +
            (lastElapsed * rewardRate * 1e18) /
            token.balanceOf(address(this));
    }

    function updateReward() public {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
    }

    function UnstakeAll() external onlyOwner {
        if (CONTRACT_RENOUNCED == true) {
            revert("Unable to perform this action");
        }
        for (uint i = 0; i < stakerList.length; i++) {
            address user = stakerList[i];
            _unstake(user);
        }
    }

    function CheckContractRenounced() external view returns (bool) {
        return CONTRACT_RENOUNCED;
    }
}
