const { expect } = require('chai');
const { ethers } = require('hardhat');
const { BigNumber } = require('ethers');

describe('Mapping', function () {
  async function deploy() {
    // ids
    const ids = new Array(10000).fill().map((_, i) => i);

    // values
    const values = new Array(10).fill().map((_, i) => BigNumber.from(i));

    // indices
    const indices = [];
    ids.forEach(id => {
      indices[id] = BigNumber.from(Math.floor(Math.random() * values.length));
    });

    // packed indices
    const indicesPerIndex = 256 / 4;
    const packedIndices = [];
    // loop through all indices, packing into a uint256
    for (let i = 0; i < indices.length; i += indicesPerIndex) {
      let bytes = [];
      for (let j = i; j < i + indicesPerIndex && j < indices.length; j += 2) {
        // a byte is uint8, so pack two uint4 into a uint8.
        let byte = indices[j].toNumber();
        byte += indices[j + 1].toNumber() << 4;
        // push byte into array
        bytes.push(byte);
      }

      // create a uint256 from bytes
      packedIndices.push(BigNumber.from(bytes.reverse()));
    }

    const UnOptimisedMapping = await ethers.getContractFactory('UnOptimisedMapping');
    const unoptimisedMapping = await UnOptimisedMapping.deploy(indices, values);
    await unoptimisedMapping.deployed();

    const OptimisedMapping = await ethers.getContractFactory('OptimisedMapping');
    const optimisedMapping = await OptimisedMapping.deploy(packedIndices, values);
    await optimisedMapping.deployed();

    return { unoptimisedMapping, optimisedMapping, ids, indices };
  }

  describe('getValue', () => {
    let unoptimisedMapping;
    let optimisedMapping;
    let ids;
    let indices;

    beforeEach('load fixture', async () => {
      ({ unoptimisedMapping, optimisedMapping, ids, indices } = await deploy())
    })

    it('optimisedMapping should get the correct values', async () => {
      for (let i = 0; i < ids.length; i++) {
        const id = ids[i];
        const a = await optimisedMapping.getValue(id)

        expect(a).to.equal(indices[i])
      }
    });

    it('unoptimisedMapping should get the correct values', async () => {
      for (let i = 0; i < ids.length; i++) {
        const id = ids[i];
        const a = await unoptimisedMapping.getValue(id)

        expect(a).to.equal(indices[i])
      }
    });
  });
});
