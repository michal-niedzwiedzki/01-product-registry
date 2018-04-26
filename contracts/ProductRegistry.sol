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
        address owner;
        uint price;
        bool exists;
    }

    event ProductRegistered(address indexed owner, uint price);
    event ProductDeregistered(address indexed owner);

    Product[] internal products;
    uint internal productsCount;
    mapping (address => uint) internal productIds;

    function registerProduct(address owner, uint price)
    external
    onlyOwner
    {
        uint productId = productIds[owner];
        Product memory product = Product({owner: owner, price: price, exists: true});

        if (products.length == 0 || products[productId].owner != owner) {
            productId = products.push(product) - 1;
            productIds[owner] = productId;
            productsCount++;
        } else {
            products[productId] = product;
        }

        ProductRegistered(owner, price);
    }

    function deregisterProduct(address owner)
    external
    onlyOwner
    {
        if (products.length == 0) {
            return;
        }

        uint productId = productIds[owner];
        Product storage product = products[productId];

        if (product.exists && product.owner == owner) {
            product.exists = false;
            productsCount--;
            ProductDeregistered(owner);
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
            if (products[i].exists) {
                addresses[j] = products[i].owner;
                j++;
            }
        }
        return addresses;
    }

    function isProductRegistered(address owner)
    external
    view
    returns (bool)
    {
        if (products.length == 0) {
            return false;
        }
        uint productId = productIds[owner];
        Product storage product = products[productId];
        return product.exists && product.owner == owner;
    }

    function getProductPrice(address owner)
    external
    view
    returns (uint)
    {
        require(products.length != 0);
        uint productId = productIds[owner];
        Product storage product = products[productId];
        require(product.exists && product.owner == owner);
        return product.price;
    }

}