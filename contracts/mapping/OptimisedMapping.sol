// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract OptimisedMapping {
    mapping(uint256 => uint256) public packedIndices;
    mapping(uint256 => uint256) public packedValues;

    constructor(uint256[] memory _packedIndices, uint256[] memory _packedValues)
    {
        uint256 indicesLength = _packedIndices.length;
        for (uint256 i = 0; i < indicesLength; ) {
            packedIndices[i] = _packedIndices[i];

            unchecked {
                ++i;
            }
        }

        uint256 valuesLength = _packedValues.length;
        for (uint256 i = 0; i < valuesLength; ) {
            packedValues[i] = _packedValues[i];

            unchecked {
                ++i;
            }
        }
    }

    function getValue(uint256 id) external view returns (uint256 value) {
        unchecked {
            uint256 valueIndex = getValueIndex(id);

            uint256 bitLength = 16;
            uint256 indicesPerIndex = 256 / bitLength;
            uint256 bitMask = (1 << bitLength) - 1;

            uint256 index = valueIndex / indicesPerIndex;
            uint256 subIndex = valueIndex % indicesPerIndex;
            uint256 shift = bitLength * subIndex;
            uint256 subIndexMask = bitMask << shift;

            return (packedValues[index] & subIndexMask) >> shift;
        }
    }

    function getValueIndex(uint256 id)
        internal
        view
        returns (uint256 valueIndex)
    {
        unchecked {
            uint256 bitLength = 4;
            uint256 indicesPerIndex = 256 / bitLength;
            uint256 bitMask = (1 << bitLength) - 1;

            uint256 index = id / indicesPerIndex;
            uint256 subIndex = id % indicesPerIndex;
            uint256 shift = bitLength * subIndex;
            uint256 subIndexMask = bitMask << shift;

            return (packedIndices[index] & subIndexMask) >> shift;
        }
    }
}
