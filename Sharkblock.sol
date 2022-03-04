// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Sharkblock {
    struct Shark {
        uint256 date;
        uint256 amount;
        address addr;
    }

    struct Campaign {
        string category;
        string title;
        string description;
        uint256 goal;
        uint256 startDate;
        uint256 endDate;
    }
    enum Status {
        PENDING,
        ACTIVE,
        CLOSED
    }
    Status status = Status.PENDING;
    address public owner = msg.sender;
    Shark[] public sharks;
    Campaign public campaign;
    string[] public images;
    mapping(address => Shark) balances;

    event Investment(address addr, uint256 amount);
    event Transfer(address addr, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Have Access");
        _;
    }
    modifier isGoalreach() {
        uint256 _total = msg.value + address(this).balance;
        require(address(this).balance < campaign.goal, "Goal already reached");
        require(_total <= campaign.goal, "Amount exceeding goals");
        _;
    }

    modifier isMature() {
        require(campaign.endDate < block.timestamp, "Campaign is Ended!");
        _;
    }

    modifier isClosed() {
        require(status != Status.CLOSED, "Campaign is Closed, Try Next time!");
        _;
    }

    constructor(
        string memory _category,
        string memory _title,
        string memory _description,
        uint256 _goal,
        string[] memory _images
    ) {
        status = Status.ACTIVE;
        images = _images;
        Campaign memory newCamp = Campaign(
            _category,
            _title,
            _description,
            _goal,
            block.timestamp,
            block.timestamp + 10 days
        );
        campaign = newCamp;
    }

    function isMaturedFunction() internal view returns (bool) {
        if (campaign.endDate < block.timestamp) return true;
        return false;
    }

    function closeCampaign() public isClosed {
        status = Status.CLOSED;
    }

    function investNow() public payable isClosed isMature {
        Shark memory newShark = Shark(block.timestamp, msg.value, msg.sender);
        sharks.push(newShark);
        balances[msg.sender] = newShark;
        emit Investment(msg.sender, msg.value);
    }

    function getMyinvestment() public view returns (Shark memory) {
        return balances[msg.sender];
    }

    function getDaysDiff() public view isMature isClosed returns (uint256) {
        return (campaign.endDate - campaign.startDate) / 60 / 60 / 24;
    }

    function getImages() public view returns (string[] memory) {
        return images;
    }

    function getTransactions() public view returns (Shark[] memory) {
        return sharks;
    }

    function getCampaignDetails() public view returns (Campaign memory) {
        return campaign;
    }

    function getMyCampaignFund() public view returns (uint256) {
        return address(this).balance;
    }

    function tranferFromCampaign() public onlyOwner {
        address payable addr = payable(owner);
        uint256 amount = address(this).balance;

        addr.transfer(amount);
        emit Transfer(addr, amount);
    }

    function init(
        string memory _category,
        string memory _title,
        string memory _description,
        uint256 _goal,
        string[] memory _images
    ) public {
        status = Status.ACTIVE;
        images = _images;
        Campaign memory newCamp = Campaign(
            _category,
            _title,
            _description,
            _goal,
            block.timestamp,
            block.timestamp + 10 days
        );
        campaign = newCamp;
    }
}
