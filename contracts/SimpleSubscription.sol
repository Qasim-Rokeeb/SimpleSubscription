// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title NFTMarketplace
 * @dev A minimal NFT minting and marketplace contract with royalties and marketplace fees.
 *      - Users can mint NFTs with a royalty percentage (max 10%).
 *      - NFTs can be listed for sale with a fixed price in ETH.
 *      - Buyers pay exact price; royalties and marketplace fees are automatically distributed.
 *      - Owner can adjust marketplace fee (max 10%).
 * 
 * Security Notes:
 * - No ERC721 transfer compatibility — ownership is managed manually in mappings.
 * - All ETH transfers are done via `transfer` (gas-limited to 2300), which may revert for smart contract wallets.
 * - Does not support batch operations or bidding.
 */
contract NFTMarketplace {

    /**
     * @dev Represents a listing for sale in the marketplace.
     */
    struct Listing {
        address seller;   // Current owner who listed the NFT
        uint256 tokenId;  // NFT identifier
        uint256 price;    // Sale price in wei
        bool active;      // Listing status
    }
    
    /**
     * @dev Represents the NFT's details, including creator and royalty percentage.
     */
    struct NFT {
        uint256 tokenId;      // NFT unique ID
        address creator;      // Original creator (receives royalties on every sale)
        string tokenURI;      // Metadata URI (JSON with image, attributes, etc.)
        uint256 royalty;      // Royalty percentage in basis points (100 = 1%, max 1000 = 10%)
    }
    
    // =========================
    // STORAGE VARIABLES
    // =========================

    mapping(uint256 => NFT) public nfts;            // tokenId → NFT metadata
    mapping(uint256 => Listing) public listings;    // tokenId → Listing details
    mapping(uint256 => address) public tokenOwners; // tokenId → Current owner address
    mapping(address => uint256) public balances;    // owner → Number of NFTs owned
    mapping(uint256 => address) public tokenApprovals; // tokenId → approved address (ERC721-like)
    mapping(address => mapping(address => bool)) public operatorApprovals; // owner → (operator → approval status)
    
    uint256 public nextTokenId;          // ID for the next minted NFT
    uint256 public marketplaceFee = 250; // Fee in basis points (250 = 2.5%)
    address public owner;                // Marketplace admin

    // =========================
    // EVENTS
    // =========================

    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Sold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event Unlisted(uint256 indexed tokenId);
    
    // =========================
    // MODIFIERS
    // =========================

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // =========================
    // CONSTRUCTOR
    // =========================

    constructor() {
        owner = msg.sender;  // Deploying address becomes marketplace owner
        nextTokenId = 1;     // Token IDs start from 1 for clarity
    }
    
    // =========================
    // CORE FUNCTIONS
    // =========================
    
    /**
     * @notice Mint a new NFT
     * @dev Assigns ownership to caller, stores royalty, and sets metadata URI.
     * @param _tokenURI Metadata URI (should point to off-chain JSON file).
     * @param _royalty Royalty percentage in basis points (max 1000 = 10%).
     */
    function mintNFT(string memory _tokenURI, uint256 _royalty) external {
        require(_royalty <= 1000, "Royalty too high"); // Enforce royalty cap
        
        uint256 tokenId = nextTokenId;
        nextTokenId++; // Increment for next mint
        
        // Save NFT details
        nfts[tokenId] = NFT({
            tokenId: tokenId,
            creator: msg.sender,
            tokenURI: _tokenURI,
            royalty: _royalty
        });
        
        // Assign ownership
        tokenOwners[tokenId] = msg.sender;
        balances[msg.sender]++;
        
        emit NFTMinted(tokenId, msg.sender, _tokenURI);
    }
    
    /**
     * @notice List an owned NFT for sale
     * @param _tokenId NFT ID
     * @param _price Price in wei (must be > 0)
     */
    function listNFT(uint256 _tokenId, uint256 _price) external {
        require(tokenOwners[_tokenId] == msg.sender, "Not owner");
        require(_price > 0, "Price must be greater than 0");
        
        listings[_tokenId] = Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            active: true
        });
        
        emit Listed(_tokenId, msg.sender, _price);
    }
    
    /**
     * @notice Purchase an NFT
     * @dev Transfers ownership, pays seller, creator (royalty), and owner (market fee).
     * @param _tokenId NFT ID to purchase.
     */
    function buyNFT(uint256 _tokenId) external payable {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "Not for sale");
        require(msg.value == listing.price, "Incorrect price sent");
        
        address seller = listing.seller;
        uint256 price = listing.price;
        
        // Fee calculations
        uint256 marketFee = (price * marketplaceFee) / 10000;
        uint256 royaltyFee = (price * nfts[_tokenId].royalty) / 10000;
        uint256 sellerAmount = price - marketFee - royaltyFee;
        
        // Update ownership
        tokenOwners[_tokenId] = msg.sender;
        balances[seller]--;
        balances[msg.sender]++;
        
        // Distribute funds
        payable(seller).transfer(sellerAmount);               // Seller
        payable(nfts[_tokenId].creator).transfer(royaltyFee); // Creator royalty
        payable(owner).transfer(marketFee);                   // Marketplace fee
        
        listing.active = false; // Mark listing inactive
        
        emit Sold(_tokenId, msg.sender, seller, price);
    }
    
    /**
     * @notice Cancel a listing
     * @param _tokenId NFT ID
     */
    function unlistNFT(uint256 _tokenId) external {
        require(listings[_tokenId].seller == msg.sender, "Not seller");
        
        listings[_tokenId].active = false;
        
        emit Unlisted(_tokenId);
    }
    
    // =========================
    // VIEW FUNCTIONS
    // =========================
    
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwners[_tokenId];
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return nfts[_tokenId].tokenURI;
    }
    
    // =========================
    // ADMIN FUNCTIONS
    // =========================
    
    /**
     * @notice Update marketplace fee
     * @dev Fee is in basis points; max 1000 (10%).
     * @param _fee New fee
     */
    function setMarketplaceFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high");
        marketplaceFee = _fee;
    }
}
