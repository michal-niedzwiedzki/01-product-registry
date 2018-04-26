pragma solidity 0.4.19;

/*

I

Stworzyc kontrakt pozwalajacy na rejestracje produktow.
Kazdy produkt zawiera swoja cene i jest identyfikowany przez adres ethereum
Tylko wlasciciel moze rejestrowac nowe produkty.
Tylko wasciciel powinien miec mozliwosc usuwania produktow.
Kontrakt powinien umozliwiac sprawdzenie czy pod danym adresem jest zarejestrowany produkt.
Kontrakt powinien umozliwac sprawdzenie ile jest wart produkt zarejestrowany pod danym adresem.
Kontrakt powiniem umozliwiac pobranie tablicy ze wszystkimi zarejestrowanymi produktami (adresy, bez cen) 

II

+ Zmienilbym nazwe pola "addr" w strukturze na inna ktora by lepiej sugerowala co adres oznacza. W tym przypadku np. "owner"
+ Debugowy event powinien byc usuniety
+ Wizualnie kod jest bardzo zbity, dalbym entery np. przed / po bloku if. rozdzielil inicjalizacje zmiennych itp.
- Funkcje powinny logicznie byc rozbite na sprawdzanie warunkow (np. if(products.length == 0) return) i faktyczna logike funkcji. Najlepiej zrobic to za pomoca modifier-ow. 
- Powyzszy warunek powtarza sie w kodzie pare razy, uzycie modifiera rozwiazalo by problem duplikacji kodu
- Nie ma potrzeby zeby wlasciciel byl w stanie edytowac cene produktu. W tym systemie wartosc raz zakupionego produktu powinna byc nie zmienna. Jezeli wlasciciel bedzie chcial zmienic cene, moze to zrobic tworzac nowy produkt i konfigurujac sprzedawany program tak aby akceptowal oba ID produktu jako poprawne licencje. Usuniecie tej logiki z funkcji registerProduct uprosci jej implementacje
- W solidity jestesmy nagradzani za zwalnianie pamieci, w funkcji deregisterProduct nie korzystamy z tego. Zastanow sie jak mozna by zmienic ta funkcje, i mozliwe ze sposob trzymania danych o licencjach, aby przy usuwaniu produktow zwalniac pamiet
- w funkcji isProductRegistered 2gi warunek logiczny nie jest potrzebny: product.exists && product.addre == at. Dla produktu ktory nie jest zainicjalizowany wartosc exists bedzie miala domyslnie zawsze wartosc false

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