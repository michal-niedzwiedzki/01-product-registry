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

*/

import { Ownable } from "node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";


contract ProductRegistry is Ownable {

    struct Product {
        uint price;
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

    mapping (address => Product) internal products;
    address[] internal productsList;

    function registerProduct(address owner, uint price)
    external
    onlyOwner
    productDoesNotExist(owner)
    {
        require(price != 0);

        productsList.push(owner);
        products[owner] = Product({price: price});

        ProductRegistered(owner, price);
    }

    function deregisterProduct(address owner)
    external
    onlyOwner
    productDoesExist(owner)
    {
        for (uint i = 0; i < productsList.length; i++) {
            if (productsList[i] == owner) {
                delete productsList[i];
            }
        }

        delete products[owner];

        ProductDeregistered(owner);
    }

    function deregisterAll()
    external
    onlyOwner
    {
        for (uint i = 0; i <= productsList.length; i++) {
            address productAddress = productsList[i];
            delete products[productAddress];
        }
        delete productsList;

        AllProductsDeregistered();
    }

    function getProductAddresses()
    external
    view
    returns (address[])
    {
        uint productsCount;
        uint listedCount;
        uint i;
        address[] memory addresses;

        for (i = 0; i < productsList.length; i++) {
            if (productsList[i] != 0) {
                productsCount++;
            }
        }

        addresses = new address[](productsCount);

        for (i = 0; i < productsList.length; i++) {
            address productAddress = productsList[i];
            if (products[productAddress].price != 0) {
                addresses[listedCount] = productAddress;
                listedCount++;
            }
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

}