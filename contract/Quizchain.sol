// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OnChainQuiz {
    address public owner;
    uint256 public questionCount;

    struct Question {
        string questionText;
        string correctAnswer;
        bool exists;
    }

    struct PlayerAnswer {
        bool answered;
        bool isCorrect;
    }

    mapping(uint256 => Question) public questions;
    mapping(address => mapping(uint256 => PlayerAnswer)) public playerAnswers;

    event QuestionAdded(uint256 questionId, string questionText);
    event AnswerSubmitted(address player, uint256 questionId, bool isCorrect);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add a question with a verified answer
    function addQuestion(string memory _questionText, string memory _correctAnswer)
        public
        onlyOwner
    {
        questionCount++;
        questions[questionCount] = Question(_questionText, _correctAnswer, true);
        emit QuestionAdded(questionCount, _questionText);
    }

    // Users can submit answers
    function submitAnswer(uint256 _questionId, string memory _answer) public {
        require(questions[_questionId].exists, "Question does not exist");
        require(!playerAnswers[msg.sender][_questionId].answered, "Already answered");

        bool correct = keccak256(abi.encodePacked(_answer)) ==
                       keccak256(abi.encodePacked(questions[_questionId].correctAnswer));

        playerAnswers[msg.sender][_questionId] = PlayerAnswer(true, correct);

        emit AnswerSubmitted(msg.sender, _questionId, correct);
    }

    // Check if user answered correctly
    function checkAnswer(address _player, uint256 _questionId) public view returns (bool) {
        return playerAnswers[_player][_questionId].isCorrect;
    }
}
