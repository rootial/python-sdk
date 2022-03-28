from thirdweb.core.classes.base_contract import BaseContract
from thirdweb.core.classes.ipfs_storage import IpfsStorage
from thirdweb.core.classes.provider_handler import ProviderHandler
from thirdweb.contracts import Token, Edition, NFTCollection

from eth_account.account import LocalAccount
from typing import Any, Dict, Optional, Type, Union, cast
from web3 import Web3

from thirdweb.types.sdk import SDKOptions


class ThirdwebSDK(ProviderHandler):
    __contract_cache: Dict[str, Union[NFTCollection, Edition, Token]] = {}
    __storage: IpfsStorage

    def __init__(
        self,
        provider: Web3,
        signer: Optional[LocalAccount],
        options: SDKOptions = SDKOptions(),
        storage: IpfsStorage = IpfsStorage(),
    ):
        """
        Initialize the thirdweb SDK.

        :param provider: web3 provider instance to use for getting on-chain data
        :param signer: signer to use for sending transactions
        :param options: optional SDK configuration options
        :param storage: optional IPFS storage instance to use for storing data
        """

        super().__init__(provider, signer, options)
        self.__storage = storage

    def get_nft_collection(self, address: str) -> NFTCollection:
        """
        Returns an NFT Collection contract SDK instance

        :param address: address of the NFT Collection contract
        :returns: NFT Collection contract SDK instance
        """

        return cast(NFTCollection, self._get_contract(address, NFTCollection))

    def get_edition(self, address: str) -> Edition:
        """
        Returns an Edition contract SDK instance

        :param address: address of the Edition contract
        :returns: Edition contract SDK instance
        """

        return cast(Edition, self._get_contract(address, Edition))

    def get_token(self, address: str) -> Token:
        """
        Returns a Token contract SDK instance

        :param address: address of the Token contract
        :returns: Token contract SDK instance
        """

        return cast(Token, self._get_contract(address, Token))

    def update_provider(self, provider: Web3):
        """
        Update the provider instance used by the SDK.

        :param provider: web3 provider instance to use for getting on-chain data
        """

        super().update_provider(provider)

        for contract in self.__contract_cache.values():
            contract.on_provider_updated(provider)

    def update_signer(self, signer: Optional[LocalAccount]):
        """
        Update the signer instance used by the SDK.

        :param signer: signer to use for sending transactions
        """

        super().update_signer(signer)

        for contract in self.__contract_cache.values():
            contract.on_signer_updated(signer)

    def _get_contract(
        self,
        address: str,
        contract_type: Union[Type[NFTCollection], Type[Edition], Type[Token]],
    ) -> Union[NFTCollection, Edition, Token]:
        if address in self.__contract_cache:
            return self.__contract_cache[address]

        contract = contract_type(
            self.get_provider(),
            address,
            self.__storage,
            self.get_signer(),
            self.get_options(),
        )

        self.__contract_cache[address] = contract
        return contract
