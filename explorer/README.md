# Explorer

## Requirements

- [Erlang 26](https://github.com/asdf-vm/asdf-erlang)
- [Elixir 1.16.2](https://elixir-ko.github.io/install.html), compiled with OTP 26
- [Phoenix 1.7.12](https://hexdocs.pm/phoenix/installation.html)

## Local development

### Set up environment variables

Run the following command to set up the environment variables:

```sh
make create_env
```

This will create a `.env` file in the `/explorer` directory of the project. The `.env` file will contain the following variables:

| Variable | Description |
| -------- | ----------- |
| `RPC_URL` | The RPC URL of the network you want to connect to. |
| `ENVIRONMENT` | The environment you want to run the application in. It can be `devnet`, `holesky` or `mainnet`. |

### Run devnet environment (optional)

If you want to run the devnet environment, you can run the following command in another terminal:

```sh
make run_local
```

<details>
<summary>
    Or alternatively you can manually run the following commands:
</summary>

```sh
cd ..
make anvil_start
```

Then in another terminal, you can run the following command to run the operator:

```sh
make operator_full_registration
make operator_start
```

Then, in another terminal, run the following command to start the aggregator:

```sh
make aggregator_start
```

Finally, to have a task running in the devnet, you can run the following command:

```sh
make send_plonk_bls12_381_proof_loop
```

</details>

### Run the frontend

To start your Phoenix server:

```makefile
cd explorer
make <run | deps | help>
```

| Command | Description |
| --- | --- |
| `make run` | Starts the Elixir backend server. |
| `make deps` | Installs Elixir code dependencies. |
| `make help` | Shows the help message. |

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
You can access to a tasks information by visiting `localhost:4000/tasks/:id`.

### Upgrade Aligned ABI

Keep in mind when the contracts are updated, the ABI of the contracts must be updated in the frontend.

If you want to update the ABI of the contracts, you can run the following commands:

```bash
cd ..
make build_aligned_contracts
cd contracts/out/
```

This will generate new contracts in the `/contracts/out/AlignedLayerServiceManager.sol` folder in the root of the project.

Once in there copy the contents of the file after `{"abi":` and before `,"bytecode":{"object":`.

Once copied, either create or replace the `AlignedLayerServiceManager.json` file, located in the `/explorer/lib/abi` directory, by pasting the content from your clipboard.

## Contributing

We appreciate your interest in contributing to the Aligned Explorer! Your contributions can help make this project even better.

PRs are more than welcome if you want to collaborate to the project. If you don't know how to implement a feature, you are still welcome to create an issue and don't forget to add the `frontend` label!

### Get in Touch

If you have any questions, suggestions, or if you'd like to contribute in any way, please feel free to reach out to us:

- **Discord**: [Aligned](https://discord.gg/alignedlayer)
- **GitHub Issues**: [Open an Issue](https://github.com/yetanotherco/aligned_layer/labels/frontend)
