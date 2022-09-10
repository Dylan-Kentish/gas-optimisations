# Optimising mapping storage

> You can think of mappings as hash tables, which are virtually initialised such that every possible key exists and is mapped to a value whose byte-representation is all zeros, a type’s default value. The similarity ends there, the key data is not stored in a mapping, only its keccak256 hash is used to look up the value.

Extract from: *https://docs.soliditylang.org/en/latest/types.html?highlight=mapping#mapping-types*

Due to the nature of the keccak256 hash, storing a mapping of `uint8 => uint256` is no more optimal than `uint256 => uint256`, beacuse the same amount of storage is used to store the keccak256 hash. Therefore, it is more optimal to maximise the number of bits used in the key.


## Context
This problem is common amongst NFT rarity. Lets assume:

- 10,000 NFT tokens
- 10 rarity values
- rarity values from 1 - 1000

Typically that would involve somthing like ([UnOptimisedMapping](./UnOptimisedMapping.sol)):

```
mapping(uint256 => uint256) public indices;
mapping(uint256 => uint256) public values;
```
Accessing the values with
```
function getValue(uint256 id) external view returns (uint256 value) {
    return values[indices[id]];
}
```

Here the a tokenId is mapped to a value index via the indices mapping. The value index then provides the rarity value. While this does provide the requried functionality. In this example we only have 10 rarity values, which makes a uint256 index far too big, and the rarity values require no more than 10 bits to store.

## Solution
In this example we only need to store an index value from 0 - 9. This makes `uint4` indices appropriate. The rarity values require uint10 to store.

As already discussed storing a mapping of `uint4` would be no better. The solution is to pack these `uint4` and `uint10` values into a `uint256`, maximising the use of available bits. 

The mappings remain unchanged, other than name ([OptimisedMapping](./OptimisedMapping.sol)):
```
mapping(uint256 => uint256) public packedIndices;
mapping(uint256 => uint256) public packedValues;
```
Accessing the values with 
```
function getValue(uint256 id) external view returns (uint256 value) {
    unchecked {
        uint256 valueIndex = getValueIndex(id);

        uint256 bitLength = 10;
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
```
Here the index is mapped to a `uint4` stored within the `uint256` and the `uint10` values are stored within the `uint256`.

To store an index with a different bit length simply alter the `bitLength` accordingly.

For the contract to behave as expected the data arrays provided to the contract must be packed correctly as Little Endian.

## How optimal is the packing
Ultimately this is dependant on the size and number of indices being packed. Smaller indices mean more can be packed into a single `uint256`, the more indices being packed the greater the overall affect.

TODO: compare the gas fee between the optimised and unoptimised contracts.

TODO: compare the difference of setting the values of indices and values.