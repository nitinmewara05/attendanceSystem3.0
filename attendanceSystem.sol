// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract AttendanceSystem {
    address public owner;
    mapping(address => bool) public employees;
    mapping(address => Employee) public employeeInfo;
    mapping(address => mapping(uint256 => uint256)) public checkInTimes;
    mapping(address => mapping(uint256 => uint256)) public checkOutTimes;

    event EmployeeRegistered(address employeeAddress, string name, uint256 employeeId, string dob, string mobileNumber, string email, string designation);
    event EmployeeCheckedIn(address employee, uint256 timestamp);
    event EmployeeCheckedOut(address employee, uint256 timestamp);
    event AdminCheckedIn(address employee, uint256 timestamp);
    event AdminCheckedOut(address employee, uint256 timestamp);
    event EmployeeRemoved(address employeeAddress);

    struct Employee {
        string name;
        uint256 employeeId;
        string dob;
        string mobileNumber;
        string email;
        string designation;
        bool registered;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    modifier onlyRegisteredEmployee() {
        require(employees[msg.sender], "Employee not registered");
        _;
    }

    function addEmployee(address employeeAddress, string memory name, uint256 employeeId, string memory dob, string memory mobileNumber, string memory email, string memory designation) external onlyOwner {
        employees[employeeAddress] = true;
        employeeInfo[employeeAddress] = Employee(name, employeeId, dob, mobileNumber, email, designation, true);
        emit EmployeeRegistered(employeeAddress, name, employeeId, dob, mobileNumber, email, designation);
    }

    function removeEmployee(address employeeAddress) external onlyOwner {
        employees[employeeAddress] = false;
        delete employeeInfo[employeeAddress];
        emit EmployeeRemoved(employeeAddress);
    }

    function checkIn() external onlyRegisteredEmployee {
        uint256 currentTime = block.timestamp;
        checkInTimes[msg.sender][currentTime] = currentTime;
        emit EmployeeCheckedIn(msg.sender, currentTime);
    }

    function checkOut() external onlyRegisteredEmployee {
        uint256 currentTime = block.timestamp;
        checkOutTimes[msg.sender][currentTime] = currentTime;
        emit EmployeeCheckedOut(msg.sender, currentTime);
    }

    function adminCheckIn(address employeeAddress) external onlyOwner {
        uint256 currentTime = block.timestamp;
        checkInTimes[employeeAddress][currentTime] = currentTime;
        emit AdminCheckedIn(employeeAddress, currentTime);
    }

    function adminCheckOut(address employeeAddress) external onlyOwner {
        uint256 currentTime = block.timestamp;
        checkOutTimes[employeeAddress][currentTime] = currentTime;
        emit AdminCheckedOut(employeeAddress, currentTime);
    }

    function getEmployeeCheckInTime(address employeeAddress, uint256 timestamp) external view returns (uint256) {
        return checkInTimes[employeeAddress][timestamp];
    }

    function getEmployeeCheckOutTime(address employeeAddress, uint256 timestamp) external view returns (uint256) {
        return checkOutTimes[employeeAddress][timestamp];
    }

    function grantPermission(address employeeAddress) external onlyOwner {
        employees[employeeAddress] = true;
    }

    function revokePermission(address employeeAddress) external onlyOwner {
        employees[employeeAddress] = false;
        delete employeeInfo[employeeAddress];
    }
}