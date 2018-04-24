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

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title ProductRegistry
 * @dev ProductRegistry contract allows to..
 */
contract ProductRegistry is Ownable() {

    string public greetings = "hi";

    function greet() external view returns (string) {
        return greetings;
    }

}
