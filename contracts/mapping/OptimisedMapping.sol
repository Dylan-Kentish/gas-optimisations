// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract OptimisedMapping {
    // This refers to a packedIndex
    // Changing the number of bits affect the number of indices per index (uint256)
    // It is wise to keep this as a factor of 256, altough not strictly necessary.
    uint256 constant bitLength = 4;
    uint256 constant indicesPerIndex = 256 / bitLength;
    uint256 constant bitMask = (1 << bitLength) - 1;

    mapping(uint256 => uint256) public packedIndices;
    mapping(uint256 => uint256) public values;

    constructor(uint256[] memory _packedIndices, uint256[] memory _values) {
        uint256 indicesLength = _packedIndices.length;
        for (uint256 i = 0; i < indicesLength; ) {
            packedIndices[i] = _packedIndices[i];

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
        unchecked {
            uint256 index = id / indicesPerIndex;
            uint256 subIndex = id % indicesPerIndex;
            uint256 shift = bitLength * subIndex;
            uint256 subIndexMask = bitMask << shift;

            return values[(packedIndices[index] & subIndexMask) >> shift];
        }
    }
}
