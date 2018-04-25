pragma solidity 0.4.19;

/*
Stworzyc kontrakt pozwalajacy na rejestracje produktow.
Kazdy produkt zawiera swoja cene i jest identyfikowany przez adres ethereum
Tylko wlasciciel moze rejestrowac nowe produkty.
Tylko wasciciel powinien miec mozliwosc usuwania produktow.
Kontrakt powinien umozliwiac sprawdzenie czy pod danym adresem jest zarejestrowany produkt.
Kontrakt powinien umozliwac sprawdzenie ile jest wart produkt zarejestrowany pod danym adresem.
Kontrakt powiniem umozliwiac pobranie tablicy ze wszystkimi zarejestrowanymi produktami (adresy, bez cen) 
*/

import { Ownable } from "node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";


contract ProductRegistry is Ownable {

    struct Product {
        address addr;
        uint price;
        bool isLive;
    }

    event ProductRegistered(address indexed at, uint price);
    event ProductDeregistered(address indexed at);

    modifier productDoesNotExist(address at) {
        require(products.length == 0 || products[productIds[at]].isLive == false);
        _;
    }

    Product[] internal products;
    uint internal productsCount;
    mapping (address => uint) internal productIds;

    function registerProduct(address at, uint price)
    external
    onlyOwner
    productDoesNotExist(at)
    {
        uint productId = products.push(Product(at, price, true)) - 1;
        productIds[at] = productId;
        productsCount++;
        ProductRegistered(at, price);
    }

    function deregisterProduct(address at)
    external
    onlyOwner
    {
        if (products.length == 0) {
            return;
        }
        uint productId = productIds[at];
        Product storage product = products[productId];
        if (product.isLive) {
            product.isLive = false;
            productsCount--;
            ProductDeregistered(at);
        }
    }

    function getProductAddresses()
    external
    view
    returns (address[])
    {
        address[] memory addresses = new address[](productsCount);
        uint j = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isLive) {
                addresses[j] = products[i].addr;
                j++;
            }
        }
        return addresses;
    }

}