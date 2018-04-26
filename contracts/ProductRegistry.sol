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
        bool exists;
    }

    event ProductRegistered(address indexed at, uint price);
    event ProductDeregistered(address indexed at);
    event DebugLookup(address searchedFor, uint foundId, uint productsCount); // TODO remove this afterwards

    Product[] internal products;
    uint internal productsCount;
    mapping (address => uint) internal productIds;

    function registerProduct(address at, uint price)
    external
    onlyOwner
    {
        uint productId = productIds[at];
        Product memory product = Product({addr: at, price: price, exists: true});
        if (products.length == 0 || products[productId].addr != at) {
            productId = products.push(product) - 1;
            productIds[at] = productId;
            productsCount++;
        } else {
            products[productId] = product;
        }
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
        DebugLookup(at, productId, products.length);
        Product storage product = products[productId];
        if (product.exists && product.addr == at) {
            product.exists = false;
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
            if (products[i].exists) {
                addresses[j] = products[i].addr;
                j++;
            }
        }
        return addresses;
    }

    function isProductRegistered(address at)
    external
    view
    returns (bool)
    {
        if (products.length == 0) {
            return false;
        }
        uint productId = productIds[at];
        Product storage product = products[productId];
        return product.exists && product.addr == at;
    }

    function getProductPrice(address at)
    external
    view
    returns (uint)
    {
        require(products.length != 0);
        uint productId = productIds[at];
        Product storage product = products[productId];
        require(product.exists && product.addr == at);
        return product.price;
    }

}