{ pkgs, ... }:

let
  xcomposeFile = pkgs.writeText "XCompose" ''
    include "%L"
    
    <Multi_key> <a> <a> : "ä" U00E4  # a umlaut lowercase
    <Multi_key> <A> <A> : "Ä" U00C4  # A umlaut uppercase
    <Multi_key> <o> <o> : "ö" U00F6  # o umlaut lowercase
    <Multi_key> <O> <O> : "Ö" U00D6  # O umlaut uppercase
    <Multi_key> <u> <u> : "ü" U00FC  # u umlaut lowercase
    <Multi_key> <U> <U> : "Ü" U00DC  # U umlaut uppercase
    <Multi_key> <s> <s> : "ß" U00DF  # sharp s;
    '';
in
{
  home.file.".XCompose".source = xcomposeFile;
}
