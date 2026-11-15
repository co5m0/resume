# resume

co5mo's resume repository.

## [Resume File [PDF]](./resume.pdf)

## Usage

The `resume.json` is compatible with [Resumake](https://resumake.io/). To
generate the public PDF, run this command from the repository root:

```sh
nix run
```

This command builds the PDF and replaces `./resume.pdf` with a writable copy.
To build without replacing `./resume.pdf`, run `nix build`.
The build output is available at `result/resume.pdf`.

The build uses XeLaTeX with selected TeX Live packages and fonts instead of
Tectonic's full bundle. The development shell uses the same compiler.

To run the public and private generation checks, use `nix flake check`.

Keep `git-crypt` locked when you run Nix commands. Nix copies tracked flake
files into its store, where other local users can read them.

To use the script, enter the development shell:

```sh
nix develop
./generate.sh
```

For a private PDF, unlock `git-crypt` inside the shell before you run
`./generate.sh`.

The script always generates the public `resume.pdf`. If `resume.secret.json`
contains valid JSON, the script also generates `resume.secret.pdf` with private data.
`git-crypt` encrypts `resume.secret.json`.
