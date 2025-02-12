# ADX Basic

## Overview

This repository contains an example template for a basic Azure Data Explorer cluster forr use with the centralisation of Security related logs.

## Project Structure

```

```

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [Git](https://git-scm.com/)
- A GitHub account
- Azure subscription

## Setup Instructions

### 1. Clone the Repository

```sh
git clone https://github.com/LaurieRhodes/PUBLIC-adx-basic.git
cd PUBLIC-adx-basic
```

### 2. Deploy the Infrastructure

The infrastructure can be deployed using the Bicep files included in the infrastructure directory.

```sh
az deployment group create --resource-group myResourceGroup --template-file infrastructure/main.bicep --parameters infrastructure/parameters.json
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
