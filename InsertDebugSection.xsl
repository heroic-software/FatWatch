<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	
	<!-- 
	This is an XSL stylesheet to read an iPhone Settings plist document and
	insert a Debug child pane item at the end.
	
	Benjamin Ragheb <ben@benzado.com>
	2 Feb 2010
	-->

	<xsl:output 
		method="xml" 
		encoding="UTF-8"
		doctype-public="-//Apple//DTD PLIST 1.0//EN"
		doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
		/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="array[preceding-sibling::key='PreferenceSpecifiers']">
		<array>
			<xsl:apply-templates select="@*|node()"/>
			<dict>
				<key>Type</key>
				<string>PSGroupSpecifier</string>
			</dict>
			<dict>
				<key>Type</key>
				<string>PSChildPaneSpecifier</string>
				<key>Title</key>
				<string>Debug</string>
				<key>File</key>
				<string>Debug</string>
			</dict>
		</array>
	</xsl:template>

</xsl:stylesheet>
