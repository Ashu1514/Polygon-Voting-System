// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract user {

  mapping(bytes32 => address) userDetails;

  function _register(bytes32 _uid) private {
    userDetails[_uid] = msg.sender;
  }

  function registerUser(bytes32 uid) public {
    _register(uid);
  }

  function getUserPublicKey(bytes32 uid) public view returns (address) {
    return userDetails[uid];
  }

  // function deleteUser(bytes32 uid) public returns (bool){
  //   if(userDetails[uid] != address(0)){
  //     return false;
  //   }
  //   delete userDetails[uid];
  //   return true;
  // }

  function checkUserExists(bytes32 uid) public view returns (bool){
    if(userDetails[uid] != address(0)){
      return true;
    } else {
      return false;
    }
  }
}
