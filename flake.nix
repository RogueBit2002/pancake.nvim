{
	description = "Nix native Neovim package manager 'Pancake'";

	inputs = { };
	outputs = { self, nixpkgs, ... }: {
		makeNeovimPackage = { pkgs, luaConfig, label, binary ? pkgs.neovim + /bin/nvim, plugins ? [], nativeDependencies ? [] }: let
		
			prefix = "pancake_nvim-${label}";

			loader = pkgs.writeTextFile {
				name = "${prefix}-loader.lua";
				text = ''
-- Add plugins to RTP
${builtins.foldl' (lines: p: "${lines}vim.opt.runtimepath:prepend(\"${p}\")\n") "" plugins }

-- Load config
dofile("${luaConfig}")
				'';
			};

			wrapper = pkgs.writeShellScript "${prefix}-wrapper" ''
export PATH=${builtins.foldl' (acc: path: "${acc}:${path}/bin") "$PATH" nativeDependencies}
exec ${binary} --clean --cmd source${loader} "$@"
			'';
		in pkgs.stdenv.mkDerivation {
			name = prefix;

			src = null;
			dontUnpack = true;

			installPhase = ''
				mkdir -p $out/bin
				ln -s ${wrapper} $out/bin/nvim
			'';
		};
	};
}
