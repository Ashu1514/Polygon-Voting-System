// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
import "./user.sol";

contract voting {
  user userContract;
  constructor(address userContractAddress) {
    userContract = user(userContractAddress);
  }

  struct Vote{
    bytes32 uid;
    bytes32 ballot_id;
    bytes32 choice;
    uint256 timestamp;
  }

  struct Ballot{
    bytes32 ballot_id;
    bytes32 result;
    bytes32[] choices;
    uint256 start_time;
    uint256 end_time;
    uint256 total_vote_count;
  }

  struct BallotResult {
    bytes32 winner;
    uint256 vote_count;
  }

  mapping(bytes32 => mapping(bytes32 => bool)) user_vote_casted;
  mapping(bytes32 => Ballot) public ballots;
  mapping(bytes32 => Vote[]) public ballot_votes;
  mapping(bytes32 => mapping(bytes32 => uint256)) public ballot_choices;

  modifier ballotCheck(bytes32 _uid, bytes32 _ballot_id){
    require(userContract.checkUserExists(_uid), 'User does not exist!');
    require(ballots[_ballot_id].ballot_id.length != 0, "Ballot not exists!");
    _;
  }

  function createBallot(bytes32 _uid, bytes32 _ballot_id, uint256 _start_time, uint256 _end_time, bytes32[] memory _choices) public {
    require(userContract.checkUserExists(_uid), 'User does not exist!');
    require(block.timestamp < _start_time && _start_time > _end_time, "Start time is not valid!");
    require(block.timestamp < _end_time, "End time is not valid!");
    require(ballots[_ballot_id].ballot_id.length == 0, "Ballot already exists!");
    Ballot memory newBallot;
    newBallot.ballot_id = _ballot_id;
    newBallot.start_time = _start_time;
    newBallot.end_time = _end_time;
    newBallot.choices = _choices;
    ballots[_ballot_id] = newBallot;
  }

  function castVote(bytes32 _uid, bytes32 _ballot_id, bytes32 _choice) public ballotCheck(_uid, _ballot_id) {
    uint256 _timestamp = block.timestamp;
    require(_timestamp > ballots[_ballot_id].start_time && _timestamp < ballots[_ballot_id].end_time, "Voting not allowed at this time!");
    require(_choice.length > 0, "Choice is not valid");
    Ballot storage ballot = ballots[_ballot_id];
    Vote memory newVote = Vote(_uid, _ballot_id, _choice, _timestamp);
    ballot_votes[_ballot_id].push(newVote);
    ballot.total_vote_count++;
    user_vote_casted[_uid][_ballot_id] = true;
    ballot_choices[_ballot_id][_choice]++;
  }

  function fetchBallot(bytes32 _uid, bytes32 _ballot_id) public view returns (Ballot memory){
    require(userContract.checkUserExists(_uid), 'User does not exist!');
    require(ballots[_ballot_id].ballot_id.length == 0, "Ballot not exists!");
    return ballots[_ballot_id];
  }

  function updateBallotResult(bytes32 _uid, bytes32 _ballot_id) public ballotCheck(_uid, _ballot_id) returns(BallotResult memory){
    require(block.timestamp > ballots[_ballot_id].end_time, "Voing is in progress, wait till end time!");
    require(ballots[_ballot_id].result.length == 0, "Ballot's result is already updated!");

    uint256 _maxVoteCount = 0;
    bytes32 _winner;
    for(uint256 i = 0; i < ballots[_ballot_id].choices.length ; i++){
      bytes32 _choice = ballots[_ballot_id].choices[i];
      uint _votes = ballot_choices[_ballot_id][_choice];
      if(_votes > _maxVoteCount) {
        _maxVoteCount = _votes;
        _winner = _choice;
      }
    }
    ballots[_ballot_id].result = _winner;

    BallotResult memory _result;
    _result.winner = _winner;
    _result.vote_count = _maxVoteCount;
    return _result;
  }
}
