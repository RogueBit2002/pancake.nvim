{
	description = "Nix native Neovim package manager 'Pancake'";

	inputs = { };
	outputs = { self, ... }: {
		lib.make = {
			pkgs,
			label ? null,
			neovim ? pkgs.neovim,
			plugins ? [],
			environment ? [],
			config ? null
		}: let
			bootloader = pkgs.writeText "bootloader.lua" ''
${ if plugins == null || builtins.length plugins == 0 then "" else plugins
|> builtins.map (p: "vim.opt.runtimepath:prepend \"${p}\"")
|> builtins.foldl' (lines: line: "${lines}${line}\n") ""
}

${ if config == null then "" else ''
vim.opt.runtimepath:prepend "${ builtins.dirOf config }"
dofile "${ config }"
'' }
			'';

		in pkgs.symlinkJoin {
			name = "pancake" + (if label != null then "+${label}" else "");
			paths = [ pkgs.neovim ];
			nativeBuildInputs = [ pkgs.makeWrapper ];
			postBuild = ''
wrapProgram $out/bin/nvim \
--add-flag --clean \
--add-flag --cmd --add-flag source${bootloader} \
${ if environment == null || builtins.length plugins == 0 then "" else "--prefix PATH \"\" ${ pkgs.lib.makeBinPath environment }" }
'';
		};
	};
}
