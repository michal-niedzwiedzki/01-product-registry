pragma solidity 0.4.19;

/*

V

mozesz sie powoli zabrac za przetestowanie jak wyglada wywolywanie jednego kontraktu z innego kontraktu. Przygotuj osobny kontrakt ktory pobiera i zwraca liste licencje z kontraktu oryginalnego

*/


interface ProductRegistryInterface {

    function getNextAddress(address at)
    external
    view
    returns (address);

    function getProductsCount()
    external
    view
    returns (uint);

    function getFilteredCount(address, function (uint) external pure returns (bool))
    external
    view
    returns (uint);

}


contract RegistryConsumer {

    ProductRegistryInterface registry;

    function RegistryConsumer(address registryAddress)
    public
    {
        registry = ProductRegistryInterface(registryAddress);
    }

    function getProducts()
    public
    view
    returns (address[])
    {
        uint productsCount = registry.getProductsCount();
        address[] memory addresses = new address[](productsCount);
        address current = 0;

        for (uint i = 0; i < productsCount; i++) {
            current = registry.getNextAddress(current);
            addresses[i] = current;
            }

        return addresses;
    }

    function filterProduct (uint price)
    external
    pure
    returns (bool)
    {
        return price >= 100;
    }

    function getExpensiveCount()
    external
    view
    returns (uint)
    {
        return registry.getFilteredCount(this, this.filterProduct);
    }

}