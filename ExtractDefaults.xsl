<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	
	<!-- 
	This is an XSL stylesheet to read an iPhone Settings plist document and
	generate a plist of default values, suitable for use with NSUserDefaults's
	registerDefaults: method.
	
	To generate Defaults.plist from Root.plist:
		xsltproc -o Defaults.plist ExtractDefaults.xsl Root.plist
		plutil -convert binary1 Defaults.plist

	Benjamin Ragheb <ben@benzado.com>
	6 Jan 2009
	-->

	<xsl:output 
		method="xml" 
		encoding="UTF-8"
		doctype-public="-//Apple//DTD PLIST 1.0//EN"
		doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
		/>

	<!-- remove all text -->
	<xsl:template match="text()"/>
	
	<!-- replace DefaultValues with a key/value pair -->
	<xsl:template match="dict">
		<key><xsl:value-of select="key[.='Key']/following-sibling::*[1]"/></key>
		<xsl:copy-of select="key[.='DefaultValue']/following-sibling::*[1]"/>
	</xsl:template>
	
	<xsl:template match="/">
		<plist version="1.0">
		<dict>
			<xsl:apply-templates select="descendant::key[.='DefaultValue']/.."/>
		</dict>
		</plist>
	</xsl:template>

</xsl:stylesheet>
