// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HomeworkGrader {
    address public owner;

    struct Submission {
        address student;
        string answer;
        uint256 timestamp;
        uint256 grade;  // Store the grade given to the submission
    }

    // Mapping from student address to their submission
    mapping(address => Submission) public submissions;

    // Event to log the submission details
    event HomeworkSubmitted(address indexed student, string answer);
    event HomeworkGraded(address indexed student, uint256 grade, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function for students to submit their homework
    function submitHomework(string memory _answer) public {
        require(bytes(_answer).length > 0, "Answer cannot be empty");
        submissions[msg.sender] = Submission(msg.sender, _answer, block.timestamp, 0);
        emit HomeworkSubmitted(msg.sender, _answer);
    }

    // Function for the owner to grade the homework and specify the student address for reward
    function gradeHomework(address _student, uint256 _grade) public onlyOwner {
        require(submissions[_student].student == _student, "No submission from this student");
        require(_grade <= 100, "Grade must be between 0 and 100");

        submissions[_student].grade = _grade;

        // Calculate reward based on the grade (e.g., 1 ether for a perfect grade)
        uint256 reward = _grade * 1 ether / 100;

        // Emit the grading and reward event
        emit HomeworkGraded(_student, _grade, reward);

        // Transfer the reward to the specified student's address
        payable(_student).transfer(reward);
    }

    // Function to view a student's submission details
    function getSubmission(address _student) public view returns (string memory, uint256, uint256) {
        Submission memory sub = submissions[_student];
        return (sub.answer, sub.grade, sub.timestamp);
    }

    // Function to receive Ether, necessary for the contract to be able to send rewards
    receive() external payable {}
}
