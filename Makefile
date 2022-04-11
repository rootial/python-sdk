.PHONY: abi docs

test:
	poetry run brownie test --network hardhat

setup:
	rm -rf .venv
	poetry shell
	poetry install
	poetry run yarn add hardhat
	make abi

abi:
	abi-gen --language Python -o thirdweb/abi --abis abi/TWRegistry.json && mv thirdweb/abi/t_w_registry/__init__.py thirdweb/abi/t_w_registry.py && rm -rf thirdweb/abi/t_w_registry
	abi-gen --language Python -o thirdweb/abi --abis abi/TWFactory.json && mv thirdweb/abi/t_w_factory/__init__.py thirdweb/abi/t_w_factory.py && rm -rf thirdweb/abi/t_w_factory
	abi-gen --language Python -o thirdweb/abi --abis abi/TokenERC20.json && mv thirdweb/abi/token_erc20/__init__.py thirdweb/abi/token_erc20.py && rm -rf thirdweb/abi/token_erc20
	abi-gen --language Python -o thirdweb/abi --abis abi/TokenERC721.json && mv thirdweb/abi/token_erc721/__init__.py thirdweb/abi/token_erc721.py && rm -rf thirdweb/abi/token_erc721
	abi-gen --language Python -o thirdweb/abi --abis abi/TokenERC1155.json && mv thirdweb/abi/token_erc1155/__init__.py thirdweb/abi/token_erc1155.py && rm -rf thirdweb/abi/token_erc1155
	abi-gen --language Python -o thirdweb/abi --abis abi/Marketplace.json && mv thirdweb/abi/marketplace/__init__.py thirdweb/abi/marketplace.py && rm -rf thirdweb/abi/marketplace
	abi-gen --language Python -o thirdweb/abi --abis abi/ERC165.json && mv thirdweb/abi/erc165/__init__.py thirdweb/abi/erc165.py && rm -rf thirdweb/abi/erc165
	abi-gen --language Python -o thirdweb/abi --abis abi/IERC20.json && mv thirdweb/abi/ierc20/__init__.py thirdweb/abi/ierc20.py && rm -rf thirdweb/abi/ierc20
	abi-gen --language Python -o thirdweb/abi --abis abi/IERC721.json && mv thirdweb/abi/ierc721/__init__.py thirdweb/abi/ierc721.py && rm -rf thirdweb/abi/ierc721
	abi-gen --language Python -o thirdweb/abi --abis abi/IERC1155.json && mv thirdweb/abi/ierc1155/__init__.py thirdweb/abi/ierc1155.py && rm -rf thirdweb/abi/ierc1155

docs:
	rm -rf sphinx-docs
	poetry run sphinx-apidoc -o sphinx-docs . sphinx-apidoc --full -A 'Adam Majmudar'
	cd sphinx-docs && printf "\n\nimport os\nimport sys\nsys.path.insert(0,os.path.abspath('../'))\n\ndef skip(app, what, name, obj,would_skip, options):\n\tif name in ( '__init__',):\n\t\treturn False\n\treturn would_skip\ndef setup(app):\n\tapp.connect('autodoc-skip-member', skip)\n\nextensions.append('sphinx_autodoc_typehints')" >> conf.py
	cd sphinx-docs && poetry run make markdown
	rm -rf docs && mkdir docs
	mv sphinx-docs/_build/markdown/* ./docs
	rm -rf sphinx-docs
	rm docs/index.md
 