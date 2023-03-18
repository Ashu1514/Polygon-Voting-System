const user = artifacts.require("user");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("user", function (/* accounts */) {
  it("should assert true", async function () {
    await user.deployed();
    return assert.isTrue(true);
  });
});
