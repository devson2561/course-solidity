pragma solidity >=0.4.22 <0.6.0;

contract Course {
    string public name;
    string public code;
    uint256 public price;
    uint public availableSeat;
    
    address payable owner;
    
    struct Student {
        address studentAddress;
        bool isDeleted;
        string note;
    }
    
    mapping(address => Student) students;

    constructor () public {
        name = "Math 1";
        code = "MTH101";
        price = 1000000000000000; // 0.001 TCH
        availableSeat = 5;
        owner = msg.sender;
    }
    
    function getInfo () public view returns (string memory _name, string memory _code, uint256 _price, uint _availableSeat) {
        return (name, code, price, availableSeat);
    }
    
    function isRegistered (address _student) internal view returns (bool _isStudent) {
        Student memory student = students[_student];
        if (student.studentAddress == _student && !student.isDeleted) {
            return true;
        }
        return false;
    }
    
    function isOwner () public view returns (bool _isOwner) {
        return owner == msg.sender;   
    }
    
    function addSeat (uint _amount) public {
        require(isOwner(), "Permission denined.");
        availableSeat += _amount;
    }
    
    function removeSeat (uint _amount) public {
        require(isOwner(), "Permission denined.");
        bool canRemove = _amount <= availableSeat;
        require(canRemove, "Remove amount should be less than available seat");
        availableSeat -= _amount;
    }
    
    function isAvailable () public view returns (bool _isAvailable) {
        return availableSeat > 0;
    }
    
    function addStudent (address _student) public {
        require(isOwner(), "Permission denined.");
        require(isAvailable(), "Seat not available");
        
        students[_student].studentAddress = _student;
        students[_student].isDeleted = false;
        students[_student].note = "";
        
        removeSeat(1);
    }
    
    function removeStudent (address _student) public {
        require(isOwner(), "Permission denined.");
        require(isRegistered(_student), "not found.");
        students[_student].isDeleted = true;
        addSeat(1);
    }
    
    function commentStudent (address _student, string memory _note) public {
        require(isOwner(), "Permission denined.");
        students[_student].note = _note;
    }
    
    function getStudent (address _student) public view returns (address _studentAddress, string memory _note, bool _isDeleted) {
        return (
            students[_student].studentAddress,
            students[_student].note,
            students[_student].isDeleted
        );
    }
    

    function isStudent () public view returns (bool _isStudent) {
        address _student = msg.sender;
        Student memory student = students[_student];
        if (student.studentAddress == _student && !student.isDeleted) {
            return true;
        }
        return false;
    }
    
    
    function () external payable { //
        require(!isStudent(), "You have already purchased this course.");
        require(isAvailable(), "Seat not available");
        
        uint256 _price = msg.value;
        address _student = msg.sender;
        
        require(_price == price, "Price not match");
        
        students[_student].studentAddress = _student;
        students[_student].isDeleted = false;
        students[_student].note = "";
        
        availableSeat -= 1;
        
        owner.transfer(_price);
        
        
    }
}