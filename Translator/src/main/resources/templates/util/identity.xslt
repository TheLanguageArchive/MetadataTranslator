<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template name="identity-transform">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="identity"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="identity">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="identity" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>