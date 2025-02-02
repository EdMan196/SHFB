<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="2.0"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:msxsl="urn:schemas-microsoft-com:xslt"
>
	<!-- ======================================================================================== -->

	<xsl:import href="GlobalTemplates.xsl"/>

	<!-- ============================================================================================
	Code languages
	============================================================================================= -->

	<!-- This gets the language ID for syntax section and code example titles -->
	<xsl:template name="t_codeLang">
		<xsl:param name="p_codeLang"/>
		<xsl:variable name="v_codeLangLC" select="translate($p_codeLang,$g_allUpperCaseLetters,$g_allLowerCaseLetters)"/>
		<xsl:choose>
			<!-- Languages without a syntax generator.  The presentation style content files will contain any required
					 resource items for these (i.e. devlang_HTML). -->
			<xsl:when test="$v_codeLangLC = 'html' or $v_codeLangLC = 'htm'">
				<xsl:text>HTML</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'pshell' or $v_codeLangLC = 'powershell' or $v_codeLangLC = 'ps1'">
				<xsl:text>PShell</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'py'">
				<xsl:text>Python</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'sql' or $v_codeLangLC = 'sqlserver' or $v_codeLangLC = 'sql server'">
				<xsl:text>SQL</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'vbs' or $v_codeLangLC = 'vbscript'">
				<xsl:text>VBScript</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'vb-c#' or $v_codeLangLC = 'visualbasicandcsharp'">
				<xsl:text>VisualBasicAndCSharp</xsl:text>
			</xsl:when>
			<xsl:when test="$v_codeLangLC = 'xml' or $v_codeLangLC = 'xmllang' or $v_codeLangLC = 'xsl'">
				<xsl:text>XML</xsl:text>
			</xsl:when>
			<!-- Special case for XAML.  It has a syntax generator but we treat the code elements differently and must
					 use a common ID. -->
			<xsl:when test="$v_codeLangLC = 'xaml' or $v_codeLangLC = 'xamlusage'">
				<xsl:text>XAML</xsl:text>
			</xsl:when>
			<!-- None/other.  No resource items are needed for these. -->
			<xsl:when test="$v_codeLangLC = 'none' or $v_codeLangLC = 'other'">
				<xsl:value-of select="$v_codeLangLC"/>
			</xsl:when>
			<!-- If none of the above, assume it is a language with a syntax generator.  The syntax generator content
					 files will contain any required resource items for the language. -->
			<xsl:otherwise>
				<xsl:value-of select="$p_codeLang"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================================
	Code sections
	============================================================================================= -->

	<xsl:template name="t_putCodeSections">
		<xsl:param name="p_codeNodes"/>
		<xsl:param name="p_nodeCount"/>
		<xsl:param name="p_codeLangAttr" select="''"/>

		<xsl:for-each select="msxsl:node-set($p_codeNodes)">
			<xsl:choose>
				<xsl:when test="$p_codeLangAttr != ''">
					<xsl:variable name="v_codeLang">
						<xsl:call-template name="t_codeLang">
							<xsl:with-param name="p_codeLang">
								<xsl:for-each select="@*">
									<xsl:if test="name() = $p_codeLangAttr">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$v_codeLang = 'XAML'">
							<xsl:call-template name="XamlSyntaxBlock"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="t_putCodeSection">
								<xsl:with-param name="p_codeLang" select="$v_codeLang"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="t_putCodeSection" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="t_putCodeSection">
		<xsl:param name="p_codeLang" />
		<xsl:text>&#xa;&#xa;```</xsl:text>
		<xsl:if test="normalize-space($p_codeLang) != '' and $p_codeLang != 'other' and $p_codeLang != 'none'">
			<xsl:text> </xsl:text>
      <xsl:variable name="v_codeLangLC" select="translate($p_codeLang,$g_allUpperCaseLetters,$g_allLowerCaseLetters)"/>
      <xsl:choose>
        <xsl:when test="$v_codeLangLC = 'vb-c#' or $v_codeLangLC = 'visualbasicandcsharp' or $v_codeLangLC = 'c#' or $v_codeLangLC = 'csharp'">
          <xsl:text>cs</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <include item="devlang_{$p_codeLang}"/>
        </xsl:otherwise>
      </xsl:choose>
		</xsl:if>
		<xsl:text>&#xa;</xsl:text>
		<!-- Use apply-templates rather than copy-of so ddue:codeFeaturedElement nodes are transformed -->
		<xsl:apply-templates mode="preserveFormatting" />
		<xsl:text>&#xa;```&#xa;</xsl:text>
	</xsl:template>

	<!-- ============================================================================================
	XAML Syntax
	============================================================================================= -->

	<xsl:template name="XamlSyntaxBlock">
		<!-- Branch based on page type -->
		<xsl:choose>
			<!-- Display boilerplate for page types that cannot be used in XAML -->
			<xsl:when test="$g_apiTopicSubGroup='method' or $g_apiTopicSubGroup='constructor' or
                      $g_apiTopicSubGroup='interface' or $g_apiTopicSubGroup='delegate' or
                      $g_apiTopicSubGroup='field'">
				<xsl:call-template name="ShowXamlSyntaxBoilerplate"/>
			</xsl:when>

			<!-- Class and structure -->
			<xsl:when test="$g_apiTopicSubGroup='class' or $g_apiTopicSubGroup='structure'">
				<xsl:choose>
					<xsl:when test="div[@class='xamlObjectElementUsageHeading']">
						<xsl:call-template name="ShowAutogeneratedXamlSyntax">
							<xsl:with-param name="autogenContent">
								<xsl:copy-of select="div[@class='xamlObjectElementUsageHeading']"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="ShowXamlSyntaxBoilerplate">
							<xsl:with-param name="p_messageId">
								<xsl:copy-of select="."/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- Enumeration -->
			<xsl:when test="$g_apiTopicSubGroup='enumeration'">
				<xsl:choose>
					<xsl:when test="div[@class='nonXamlAssemblyBoilerplate']"/>
					<xsl:otherwise>
						<include item="xamlAttributeUsageHeading"/>
						<include item="enumerationOverviewXamlSyntax"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- Property -->
			<xsl:when test="$g_apiTopicSubGroup='property' or $g_apiTopicSubSubGroup='attachedProperty'">
				<!-- Property Element Usage -->
				<xsl:if test="div[@class='xamlPropertyElementUsageHeading' or @class='xamlContentElementUsageHeading']">
					<xsl:call-template name="ShowAutogeneratedXamlSyntax">
						<xsl:with-param name="autogenContent">
							<xsl:copy-of select="div[@class='xamlPropertyElementUsageHeading' or @class='xamlContentElementUsageHeading']"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<!-- Attribute Usage -->
				<xsl:if test="div[@class='xamlAttributeUsageHeading']">
					<xsl:call-template name="ShowAutogeneratedXamlSyntax">
						<xsl:with-param name="autogenContent">
							<xsl:copy-of select="div[@class='xamlAttributeUsageHeading']"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<!-- Show auto-generated boilerplate if no other content to override it -->
				<xsl:if test="not(div[@class='xamlPropertyElementUsageHeading' or
								@class='xamlContentElementUsageHeading' or @class='xamlAttributeUsageHeading'])">
					<xsl:call-template name="ShowXamlSyntaxBoilerplate">
						<xsl:with-param name="p_messageId">
							<xsl:copy-of select="div/*"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<!-- Event -->
			<xsl:when test="$g_apiTopicSubGroup='event' or $g_apiTopicSubSubGroup='attachedEvent'">
				<!-- If XamlSyntaxUsage component generated an Attribute Usage block, this template will show it -->
				<xsl:call-template name="ShowAutogeneratedXamlSyntax">
					<xsl:with-param name="autogenContent">
						<xsl:copy-of select="div[@class='xamlAttributeUsageHeading']"/>
					</xsl:with-param>
				</xsl:call-template>
				<!-- If XamlSyntaxUsage component generated a boilerplate block, this template will show it -->
				<xsl:call-template name="ShowXamlSyntaxBoilerplate">
					<xsl:with-param name="p_messageId">
						<xsl:copy-of select="div/*"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	<!-- Displays one of the standard XAML boilerplate strings. -->
	<xsl:template name="ShowXamlSyntaxBoilerplate">
		<xsl:param name="p_messageId"/>

		<!-- Do not show any XAML syntax boilerplate strings -->
		<xsl:variable name="boilerplateId"/>

		<!-- If future requirements call for showing one or more boilerplate strings for XAML, use the commented out
				 code to specify the ids of the shared content items to include.
         NOTE: The markup like div/@class='interfaceOverviewXamlSyntax' is added by XamlUsageSyntax.cs in
				 BuildAssembler. -->
		<!--
    <xsl:variable name="boilerplateId">
      <xsl:value-of select="div/@class[.='interfaceOverviewXamlSyntax' or
                    .='propertyXamlSyntax_abstractType' or                    
                    .='classXamlSyntax_abstract']"/>
    </xsl:variable>
    -->

		<xsl:if test="$boilerplateId != ''">
			<include item="{$boilerplateId}">
				<xsl:choose>
					<xsl:when test="$p_messageId !='' or (count(msxsl:node-set($p_messageId)/*) &gt; 0)">
						<parameter><xsl:copy-of select="msxsl:node-set($p_messageId)"/></parameter>
					</xsl:when>
					<!-- Make sure we at least pass in an empty param because some boilerplates expect them -->
					<xsl:otherwise>
						<parameter/>
					</xsl:otherwise>
				</xsl:choose>
			</include>
		</xsl:if>
	</xsl:template>

	<!-- Displays the auto-generated XAML syntax for page types other than enumerations -->
	<xsl:template name="ShowAutogeneratedXamlSyntax">
		<xsl:param name="autogenContent"/>
		<xsl:if test="count(msxsl:node-set($autogenContent))>0">
			<xsl:for-each select="msxsl:node-set($autogenContent)/div">
				<xsl:text>&#xa;|</xsl:text><include item="{@class}"/>
				<xsl:text>|</xsl:text>
				<xsl:copy-of select="node()"/>
				<xsl:text>|</xsl:text>
				<xsl:text>&#xa;</xsl:text>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
