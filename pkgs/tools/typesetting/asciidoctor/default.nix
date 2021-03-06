{ stdenv, lib, bundlerApp, ruby, curl
  # Dependencies of the 'mathematical' package
, cmake, bison, flex, glib, pkgconfig, cairo
, pango, gdk_pixbuf, libxml2, python3, patchelf
}:

bundlerApp {
  inherit ruby;
  pname = "asciidoctor";
  gemdir = ./.;

  exes = [
    "asciidoctor"
    "asciidoctor-bespoke"
    "asciidoctor-latex"
    "asciidoctor-pdf"
    "asciidoctor-safe"
    "asciidoctor-mathematical"
  ];

  gemConfig = {
    mathematical = attrs: {
      buildInputs = [
        cmake
        bison
        flex
        glib
        pkgconfig
        cairo
        pango
        gdk_pixbuf
        libxml2
        python3
      ];

      # The ruby build script takes care of this
      dontUseCmakeConfigure = true;

      # For some reason 'mathematical.so' is missing cairo and glib in its RPATH, add them explicitly here
      postFixup = lib.optionalString stdenv.isLinux ''
        soPath="$out/lib/ruby/gems/2.4.0/gems/mathematical-${attrs.version}/lib/mathematical/mathematical.so"
        ${patchelf}/bin/patchelf \
          --set-rpath "${lib.makeLibraryPath [ glib cairo ]}:$(${patchelf}/bin/patchelf --print-rpath "$soPath")" \
          "$soPath"
      '';
    };
  };

  meta = with lib; {
    description = "A faster Asciidoc processor written in Ruby";
    homepage = http://asciidoctor.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ gpyh ];
    platforms = platforms.unix;
  };
}
