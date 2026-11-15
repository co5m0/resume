{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs =
		{ self, nixpkgs, flake-utils }:

		flake-utils.lib.eachDefaultSystem (system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
				tex = pkgs.texlive.combine {
					inherit (pkgs.texlive)
						scheme-basic xetex latexmk fontspec tools hyperref etoolbox
						fontawesome preprint titlesec marvosym enumitem fancyhdr
						soul cmap ulem accsupp fontaxes xkeyval lato josefin;
				};
			in
			{
				packages.default = pkgs.runCommand "resume" {
					nativeBuildInputs = [ pkgs.gomplate tex ];
					SOURCE_DATE_EPOCH = "0";
					FORCE_SOURCE_DATE = "1";
				} ''
					export HOME="$TMPDIR"
					gomplate -c .=${./resume.json} -f ${./resume.tmpl.tex} \
						-o resume.tex --left-delim '<' --right-delim '>'
					latexmk -xelatex -interaction=nonstopmode -halt-on-error -no-shell-escape resume.tex
					install -Dm644 resume.pdf "$out/resume.pdf"
					test "$(head -c 5 "$out/resume.pdf")" = '%PDF-'
				'';

				checks.generate = pkgs.runCommand "resume-generate-check" {
					nativeBuildInputs = [ pkgs.gomplate pkgs.jq (pkgs.lib.getBin pkgs.poppler_utils) tex ];
				} ''
					export HOME="$TMPDIR"
					install -m644 ${./resume.json} resume.json
					cp ${./resume.tmpl.tex} resume.tmpl.tex
					printf 'encrypted' > resume.secret.json
					bash ${./generate.sh}
					test -s resume.pdf
					test ! -e resume.secret.pdf
					printf '{"basics":{"name":"PRIVATE TEST"}}' > resume.secret.json
					bash ${./generate.sh}
					pdftotext resume.secret.pdf - | grep -q 'PRIVATE TEST'
					if pdftotext resume.pdf - | grep -q 'PRIVATE TEST'; then exit 1; fi
					printf 'invalid' > resume.json
					if bash ${./generate.sh} >/dev/null 2>&1; then exit 1; fi
					touch "$out"
				'';

				apps.default = {
					type = "app";
					meta.description = "Copy the public PDF to ./resume.pdf";
					program = "${pkgs.writeShellScript "update-resume" ''
						exec ${pkgs.coreutils}/bin/install -m 644 ${self.packages.${system}.default}/resume.pdf ./resume.pdf
					''}";
				};

				devShell = pkgs.mkShell {
					packages = [ tex ] ++ (with pkgs; [ gomplate jq git-crypt ]);
				};
			}
		);
}
