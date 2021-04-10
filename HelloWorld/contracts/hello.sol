//SPDX-License-Identifier:UNLICENSED 
pragma solidity 0.8.3;

contract HelloWorld {
    string message = "Hi, Xyz!";

    function setMessage(string memory _newMessage) public payable {
        message = _newMessage;
    }
    function hello() public view returns (string memory){
        return message;
    }
}