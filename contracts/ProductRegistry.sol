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
+ Funkcje powinny logicznie byc rozbite na sprawdzanie warunkow (np. if(products.length == 0) return) i faktyczna logike funkcji. Najlepiej zrobic to za pomoca modifier-ow. 
+ Powyzszy warunek powtarza sie w kodzie pare razy, uzycie modifiera rozwiazalo by problem duplikacji kodu
+ Nie ma potrzeby zeby wlasciciel byl w stanie edytowac cene produktu. W tym systemie wartosc raz zakupionego produktu powinna byc nie zmienna. Jezeli wlasciciel bedzie chcial zmienic cene, moze to zrobic tworzac nowy produkt i konfigurujac sprzedawany program tak aby akceptowal oba ID produktu jako poprawne licencje. Usuniecie tej logiki z funkcji registerProduct uprosci jej implementacje
+ W solidity jestesmy nagradzani za zwalnianie pamieci, w funkcji deregisterProduct nie korzystamy z tego. Zastanow sie jak mozna by zmienic ta funkcje, i mozliwe ze sposob trzymania danych o licencjach, aby przy usuwaniu produktow zwalniac pamiet
+ w funkcji isProductRegistered 2gi warunek logiczny nie jest potrzebny: product.exists && product.addre == at. Dla produktu ktory nie jest zainicjalizowany wartosc exists bedzie miala domyslnie zawsze wartosc false

III

+ Doimplementuj funkcje "deregisterAll" ktora owner moze usunac wszystkie zarejestrowane produkty
+ Sprobuj zaimplementowac alternatywna strukture trzymania danych o produktach, tak aby operacje usuniecia dowolnego produktu, iterowania sie po nich i dodawania kolejnych byly gazowo optymalne
- Sprawdz obecne zuzycie gazu w funkcjach i zobacz czy da sie to zoptymalizowac
+ Jako hint: pomysl o zastapieniu tablicy produktow lista ze wskaznikami

IV

- przetestuj implementacje gdzie jest tylko mapping products, ale w strukturze Product przechowujesz wskaznik do kolejnego produktu

*/

import { Ownable } from "node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";


contract ProductRegistry is Ownable {

    struct Product {
        uint price;
        address next;
    }

    event ProductRegistered(address indexed owner, uint price);
    event ProductDeregistered(address indexed owner);
    event AllProductsDeregistered();

    modifier productDoesExist(address owner) {
        require(products[owner].price != 0);
        _;
    }

    modifier productDoesNotExist(address owner) {
        require(products[owner].price == 0);
        _;
    }

    modifier hasPrice(uint price) {
        require(price != 0);
        _;
    }

    mapping (address => Product) internal products;
    address productsHead;

    function registerProduct(address owner, uint price)
    external
    onlyOwner
    productDoesNotExist(owner)
    hasPrice(price)
    {
        products[owner] = Product({price: price, next: 0});

        if (productsHead == 0) {
            productsHead = owner;
        } else {
            address lastAddress = productsHead;
            while (products[lastAddress].next != 0) {
                lastAddress = products[lastAddress].next;
            }
            products[lastAddress].next = owner;
        }

        ProductRegistered(owner, price);
    }

    function deregisterProduct(address owner)
    external
    onlyOwner
    productDoesExist(owner)
    {
        if (productsHead == owner) {
            productsHead = products[owner].next;
        }
        delete products[owner];

        ProductDeregistered(owner);
    }

    function deregisterAll()
    external
    onlyOwner
    {
        for (address currentAddress = productsHead; currentAddress != 0; currentAddress = products[currentAddress].next) {
            delete products[currentAddress];
        }
        delete productsHead;

        AllProductsDeregistered();
    }

    function getProductAddresses()
    external
    view
    returns (address[])
    {
        address[] memory addresses;
        address currentAddress;
        uint productsCount;
        uint i;
        
        for (currentAddress = productsHead; currentAddress != 0; currentAddress = products[currentAddress].next) {
            productsCount++;
        }

        addresses = new address[](productsCount);
        for (currentAddress = productsHead; currentAddress != 0; currentAddress = products[currentAddress].next) {
            addresses[i] = currentAddress;
            i++;
        }

        return addresses;
    }

    function isProductRegistered(address owner)
    external
    view
    returns (bool)
    {
        return products[owner].price != 0;
    }

    function getProductPrice(address owner)
    external
    view
    productDoesExist(owner)
    returns (uint)
    {
        return products[owner].price;
    }

    function getProductsCount()
    external
    view
    returns (uint)
    {
        uint productsCount;
        for (address currentAddress = productsHead; currentAddress != 0; currentAddress = products[currentAddress].next) {
            productsCount++;
        }
        return productsCount;
    }

    function getNextAddress(address from)
    external
    view
    returns (address)
    {
        return (from == 0) ? productsHead : products[from].next;
    }

}