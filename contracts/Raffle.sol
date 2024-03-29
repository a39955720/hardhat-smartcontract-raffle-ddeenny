// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./PriceConverter.sol";

// Custom error messages
error Raffle__SendMoreToEnterRaffle();
error Raffle__TransferFailed();
error Raffle__RaffleNotOpen();

/**@title A sample Raffle Contract
 * @author DDEENNY
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */
contract Raffle is VRFConsumerBaseV2 {
    using PriceConverter for uint256;

    // Enum to represent the state of the raffle
    enum RaffleState {
        OPEN, // The raffle is open for participants to enter.
        CALCULATING // The raffle is being calculated to determine the winner.
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // Lottery Variables
    AggregatorV3Interface private immutable i_priceFeed;
    address payable private immutable i_owner;
    uint256 private constant ENTRANCEFEE = 100;
    uint256 private constant PRIZENUM = 6;
    address payable private s_participant;
    address private s_recentWinner;
    uint256 private s_drawnNumber;
    RaffleState private s_raffleState;

    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed player);

    /**
     * @notice Constructor to initialize the Raffle contract
     * @param vrfCoordinatorV2 The address of the VRFCoordinator contract
     * @param priceFeed The address of the AggregatorV3Interface contract for price feed
     * @param subscriptionId The subscription ID for Chainlink VRF
     * @param gasLane The gas lane for Chainlink VRF
     * @param callbackGasLimit The callback gas limit for Chainlink VRF
     */
    constructor(
        address vrfCoordinatorV2,
        address priceFeed,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) payable VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = payable(msg.sender);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    /**
     * @dev Allows a participant to enter the raffle by paying the entrance fee in ETH.
     * @notice The entrance fee must be equal to or greater than the specified amount in USD.
     */
    function enterRaffle() public payable {
        if (msg.value < ENTRANCEFEE.getUsdToEth(i_priceFeed)) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_raffleState = RaffleState.CALCULATING;
        s_participant = payable(msg.sender);

        // Transfer a portion of the entrance fee to the contract owner
        (bool success, ) = i_owner.call{value: msg.value / 10}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    /**
     * @notice This is the function that Chainlink VRF node calls to send the money to the winner.
     * @param randomWords The array of random words generated by Chainlink VRF
     */
    function fulfillRandomWords(
        uint256 /* requestId*/,
        uint256[] memory randomWords
    ) internal override {
        s_drawnNumber = randomWords[0] % 10;
        if (s_drawnNumber == PRIZENUM) {
            // Transfer 90% of the contract's balance to the winner
            (bool success, ) = s_participant.call{value: ((address(this).balance) * 9) / 10}("");
            if (!success) {
                revert Raffle__TransferFailed();
            }
            s_recentWinner = s_participant;
            emit WinnerPicked(s_participant);
        }
        s_raffleState = RaffleState.OPEN;
    }

    // Getter functions...
    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRecentRandNum() public view returns (uint256) {
        return s_drawnNumber;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getVRFCoordinator() public view returns (VRFCoordinatorV2Interface) {
        return i_vrfCoordinator;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getEntranceFeeInUsd() public pure returns (uint256) {
        return ENTRANCEFEE;
    }

    function getEntranceFeeInEth() public view returns (uint256) {
        return ENTRANCEFEE.getUsdToEth(i_priceFeed);
    }

    function getPrizeNumber() public pure returns (uint256) {
        return PRIZENUM;
    }
}
