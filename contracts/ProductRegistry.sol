/*

Stworzyc kontrakt pozwalajacy na rejestracje produktow.
Kazdy produkt zawiera swoja cene i jest identyfikowany przez adres ethereum
Tylko wlasciciel moze rejestrowac nowe produkty.
Tylko wasciciel powinien miec mozliwosc usuwania produktow.
Kontrakt powinien umozliwiac sprawdzenie czy pod danym adresem jest zarejestrowany produkt.
Kontrakt powinien umozliwac sprawdzenie ile jest wart produkt zarejestrowany pod danym adresem.
Kontrakt powiniem umozliwiac pobranie tablicy ze wszystkimi zarejestrowanymi produktami (adresy, bez cen) 

*/

pragma solidity 0.4.19;

import "node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title ProductRegistry
 * @dev ProductRegistry contract allows to..
 */
contract ProductRegistry is Ownable() {

    string public greetings = "hi";

    struct Product {
        address at;
        uint price;
    }

    Product[] products;
    mapping (uint => address) productAddresses;

    function greet() external view returns (string) {
        return greetings;
    }

    function registerProduct(address at, uint price) public onlyOwner {
        require(price > 0);
        uint productId = products.push(Product(at, price)) - 1;
        productAddresses[productId] = at;
    }

    function removeProduct(address at) public onlyOwner {
        uint productId = getProductIdByAddress(at);
        products[productId] = Product(0, 0);
        productAddresses[productId] = 0;
    }

    function isProductRegistered(address at) public view returns (bool) {
        uint productId = getProductIdByAddress(at);
        return productAddresses[productId] != 0;
    }

    function getProductIdByAddress(address at) internal view returns (uint) {
        for (uint i = 0; i < products.length; ++ i) {
            if (productAddresses[i] == at) {
                return i;
            }
        }
        return 0;
    }

    function getProductPrice(address at) public view returns (uint) {
        uint productId = getProductIdByAddress(at);
        return products[productId].price;
    }

    function getAllProductAddresses() public view returns (address[]) {
        address[] memory allAddresses;
        for (uint i = 0; i < products.length; ++i) {
            if (isProductRegistered(products[i].at)) {
                allAddresses[allAddresses.length] = products[i].at; // may explode due to range error, need to run and test
            }
        }
        return allAddresses;
    }

}