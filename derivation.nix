{ fetchurl, lib, stdenv, writeText, jdk, makeWrapper, nixosTests }:

stdenv.mkDerivation rec {
  pname = "soapui";
  version = "5.7.0";

  src = fetchurl {
    url = "https://s3.amazonaws.com/downloads.eviware/soapuios/${version}/SoapUI-${version}-linux-bin.tar.gz";
    sha256 = "qzhy4yHmOk13dFUd2KEZhXtWY86QwyjJgYxx9GGoN80=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp -R bin lib $out/share/java

    makeWrapper $out/share/java/bin/soapui.sh $out/bin/soapui --set SOAPUI_HOME $out/share/java

    runHook postInstall
  '';

  patches = [
    # Adjust java path to point to derivation paths
    (writeText "soapui-${version}.patch" ''
      --- a/bin/soapui.sh
      +++ b/bin/soapui.sh
      @@ -53,1 +53,1 @@ -JFXRTPATH=`java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
      -JFXRTPATH=`java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
      +JFXRTPATH=`${jdk}/bin/java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
      @@ -88,1 +88,1 @@ -java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
      -java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
      +${jdk}/bin/java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
    '')
  ];

  passthru.tests = { inherit (nixosTests) soapui; };

  meta = with lib; {
    description = "The Most Advanced REST & SOAP Testing Tool in the World";
    homepage = "https://www.soapui.org/";
    license = "SoapUI End User License Agreement";
    maintainers = with maintainers; [ gerschtli ];
    platforms = platforms.all;
  };
}

