// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract UnOptimisedMapping {
    mapping(uint256 => uint256) public indices;
    mapping(uint256 => uint256) public values;

    constructor(uint256[] memory _indices, uint256[] memory _values) {
       uint256 indicesLength = _indices.length;
        for (uint256 i = 0; i < indicesLength; ) {
            indices[i] = _indices[i];

            unchecked {
                ++i;
            }
        }

        uint256 valuesLength = _values.length;
        for (uint256 i = 0; i < valuesLength; ) {
            values[i] = _values[i];

            unchecked {
                ++i;
            }
        }
    }

    function getValue(uint256 id) external view returns (uint256 value) {
        return values[indices[id]];
    }
}
