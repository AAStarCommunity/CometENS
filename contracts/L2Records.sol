pragma solidity ^0.8.24;

contract L2Records {
    mapping(bytes32 => address) private _addr;
    mapping(bytes32 => mapping(string => string)) private _text;
    mapping(bytes32 => bytes) private _contenthash;

    function addr(bytes32 node) external view returns (address) {
        return _addr[node];
    }

    function setAddr(bytes32 node, address a) external {
        _addr[node] = a;
    }

    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return _text[node][key];
    }

    function setText(bytes32 node, string calldata key, string calldata value) external {
        _text[node][key] = value;
    }

    function contenthash(bytes32 node) external view returns (bytes memory) {
        return _contenthash[node];
    }

    function setContenthash(bytes32 node, bytes calldata ch) external {
        _contenthash[node] = ch;
    }
}
