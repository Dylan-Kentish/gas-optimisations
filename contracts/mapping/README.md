# Optimising mapping storage

Maps always store values as uint256. Therefore storing a mapping of `uint8 => uint256` is no more optimal than `uint256 => uint256` infact due to casting its actually less optimal.

## Context
This problem is common amongst NFT rarity. Lets assume:

- 10,000 NFT tokens
- 10 rarity values

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

Here the a tokenId is mapped to a value index via the indices mapping. The value index then provides the rarity value. While this does provide the requried functionality. In this example we only have 10 rarity values, which makes a uint256 index far too big.

## Solution
In this example we only need to store a value up to 10. This makes `uint4` indices appropriate.

As already discussed storing a mapping of `uint4` would be no better. The solution is to pack these `uint4` values into a `uint256`, maximising use of available bits. 

The mappings remain unchanged, other than name ([OptimisedMapping](./OptimisedMapping.sol)):
```
mapping(uint256 => uint256) public packedIndices;
mapping(uint256 => uint256) public values;
```
Accessing the values with 
```
uint256 constant bitLength = 4;
uint256 constant indicesPerIndex = 256 / bitLength;
uint256 constant bitMask = (1 << bitLength) - 1;

function getValue(uint256 id) external view returns (uint256 value) {
    unchecked {
        uint256 index = id / indicesPerIndex;
        uint256 subIndex = id % indicesPerIndex;
        uint256 subIndexMask = bitMask << (bitLength * subIndex);

        return values[packedIndices[index] & subIndexMask];
    }
}
```
Here the index is mapped to a `uint4` stored within the `uint256`. To store an index with a different bit length simply alter the `bitLength` accordingly.

## How optimal is the packing
Ultimately this is dependant on the size and number of indices being packed. Smaller indices mean more can be packed into a single `uint256`, the more indices being packed the greater the overall affect.
