pragma solidity =0.5.16;

import './interfaces/IMojitoFactory.sol';
import './MojitoPair.sol';

contract MojitoFactory is IMojitoFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(MojitoPair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Mojito: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Mojito: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Mojito: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(MojitoPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMojitoPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Mojito: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Mojito: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setSwapFeeNumerator(address _pair, uint _swapFeeNumerator) external {
        require(msg.sender == feeToSetter, 'Mojito: FORBIDDEN');
        IMojitoPair(_pair).setSwapFeeNumerator(_swapFeeNumerator);
    }

    function setFeeToDenominator(address _pair, uint _feeToDenominator) external {
        require(msg.sender == feeToSetter, 'Mojito: FORBIDDEN');
        IMojitoPair(_pair).setFeeToDenominator(_feeToDenominator);
    }
}
