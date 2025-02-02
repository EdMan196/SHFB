<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								version="2.0"
								xmlns:ddue="http://ddue.schemas.microsoft.com/authoring/2003/5"
>
	<!-- ======================================================================================== -->

	<xsl:import href="GlobalTemplates.xsl"/>
	<xsl:import href="CodeTemplates.xsl"/>
	<xsl:import href="ReferenceUtilities.xsl"/>
	<xsl:import href="Bibliography.xsl"/>

	<xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="utf-8"/>

	<!-- ============================================================================================
	Parameters
	============================================================================================= -->

	<xsl:param name="bibliographyData" select="'../Data/bibliography.xml'"/>
	<xsl:param name="omitXmlnsBoilerplate" select="'false'"/>
	<xsl:param name="omitVersionInformation" select="'false'"/>

	<!-- ============================================================================================
	Global Variables
	============================================================================================= -->

	<xsl:variable name="g_abstractSummary" select="/document/comments/summary"/>
	<xsl:variable name="g_hasSeeAlsoSection"
		select="boolean((count(/document/comments//seealso[not(ancestor::overloads)] |
		/document/comments/conceptualLink | /document/reference/elements/element/overloads//seealso |
		/document/reference/elements/element/overloads/conceptualLink) > 0) or
		($g_apiTopicGroup='type' or $g_apiTopicGroup='member' or $g_apiTopicGroup='list'))"/>
	<xsl:variable name="g_hasReferenceLinks"
		select="boolean((count(/document/comments//seealso[not(ancestor::overloads) and not(@href)] |
		/document/reference/elements/element/overloads//seealso[not(@href)]) > 0) or
		($g_apiTopicGroup='type' or $g_apiTopicGroup='member' or $g_apiTopicGroup='list'))"/>
	<xsl:variable name="g_hasOtherResourcesLinks"
		select="boolean((count(/document/comments//seealso[not(ancestor::overloads) and @href] |
		/document/comments/conceptualLink | /document/reference/elements/element/overloads//seealso[@href] |
		/document/reference/elements/element/overloads/conceptualLink) > 0))"/>

	<!-- ============================================================================================
	Body
	============================================================================================= -->

	<xsl:template name="t_body">
		<!-- auto-inserted info -->
		<xsl:apply-templates select="/document/comments/preliminary"/>

    <xsl:text>&#xa;</xsl:text>
    
		<xsl:if test="/document/reference/attributes/attribute/type[@api='T:System.ObsoleteAttribute']">
			<xsl:text>&#xa;</xsl:text>
			<include item="boilerplate_obsoleteLong"/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
    
		<xsl:apply-templates select="/document/comments/summary"/>

    <xsl:text>&#xa;</xsl:text>
    
		<xsl:if test="$g_apiTopicSubGroup='overload'">
			<xsl:apply-templates select="/document/reference/elements" mode="overloadSummary"/>
		</xsl:if>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- inheritance -->
		<xsl:apply-templates select="/document/reference/family"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- assembly information -->
		<xsl:if test="not($g_apiTopicGroup='list' or $g_apiTopicGroup='root' or $g_apiTopicGroup='namespace' or $g_apiTopicGroup='namespaceGroup')">
			<xsl:call-template name="t_putRequirementsInfo"/>
		</xsl:if>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- syntax -->
		<xsl:if test="not($g_apiTopicGroup='list' or $g_apiTopicGroup='root' or $g_apiTopicGroup='namespace' or $g_apiTopicGroup='namespaceGroup')">
			<xsl:apply-templates select="/document/syntax"/>
		</xsl:if>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- members -->
		<xsl:choose>
			<xsl:when test="$g_apiTopicGroup='root'">
				<xsl:apply-templates select="/document/reference/elements" mode="root"/>
			</xsl:when>
			<xsl:when test="$g_apiTopicGroup='namespace'">
				<xsl:apply-templates select="/document/reference/elements" mode="namespace"/>
			</xsl:when>
			<xsl:when test="$g_apiTopicGroup='namespaceGroup'">
				<xsl:apply-templates select="/document/reference/elements" mode="namespaceGroup" />
			</xsl:when>
			<xsl:when test="$g_apiTopicSubGroup='enumeration'">
				<xsl:apply-templates select="/document/reference/elements" mode="enumeration"/>
			</xsl:when>
			<xsl:when test="$g_apiTopicGroup='type'">
				<xsl:apply-templates select="/document/reference/elements" mode="type"/>
			</xsl:when>
			<xsl:when test="$g_apiTopicGroup='list'">
				<xsl:choose>
					<xsl:when test="$g_apiTopicSubGroup='overload'">
						<xsl:apply-templates select="/document/reference/elements" mode="overload"/>
					</xsl:when>
					<xsl:when test="$g_apiTopicSubGroup='DerivedTypeList'">
						<xsl:apply-templates select="/document/reference/elements" mode="derivedType"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="/document/reference/elements" mode="member"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- events -->
		<xsl:call-template name="t_events"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- exceptions -->
		<xsl:call-template name="t_exceptions"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- remarks -->
		<xsl:apply-templates select="/document/comments/remarks"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- examples -->
		<xsl:apply-templates select="/document/comments/example"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- contracts -->
		<xsl:call-template name="t_contracts"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!--versions-->
		<xsl:if test="not($g_apiTopicGroup='list' or $g_apiTopicGroup='root' or $g_apiTopicGroup='namespace' or $g_apiTopicGroup='namespaceGroup')">
			<xsl:apply-templates select="/document/reference/versions"/>
		</xsl:if>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- permissions -->
		<xsl:call-template name="t_permissions"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- thread safety -->
		<xsl:apply-templates select="/document/comments/threadsafety"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- revisions -->
		<xsl:call-template name="t_revisionHistory"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- bibliography -->
		<xsl:call-template name="t_bibliography"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- see also -->
		<xsl:call-template name="t_putSeeAlsoSection"/>

    <xsl:text>&#xa;</xsl:text>
    
		<!-- Add the full inheritance hierarchy if needed -->
		<xsl:if test="count(/document/reference/family/descendents/type) > 5">
			<xsl:apply-templates select="/document/reference/family" mode="fullInheritance"/>
		</xsl:if>

	</xsl:template>

	<!-- ============================================================================================
	Inline tags
	============================================================================================= -->

	<xsl:template match="para" name="t_para">
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="c" name="t_codeInline">
		<xsl:text>`</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>`</xsl:text>
	</xsl:template>

	<xsl:template match="preliminary" name="t_preliminary">
		<xsl:text>&#160;</xsl:text>
		<blockquote>
			<strong>
				<xsl:choose>
					<xsl:when test="normalize-space(.)">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<include item="preliminaryText" />
					</xsl:otherwise>
				</xsl:choose>
			</strong>
		</blockquote>
	</xsl:template>

	<xsl:template match="paramref" name="t_paramref">
		<xsl:text>*</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>*</xsl:text>
	</xsl:template>

	<xsl:template match="typeparamref" name="t_typeparamref">
		<xsl:text>*</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>*</xsl:text>
	</xsl:template>

	<!-- ============================================================================================
	Block sections
	============================================================================================= -->

	<xsl:template match="summary" name="t_summary">
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="value" name="t_value">
		<xsl:call-template name="t_putSubSection">
			<xsl:with-param name="p_title">
				<xsl:choose>
					<xsl:when test="/document/reference/apidata[@subgroup='property']">
						<include item="title_propertyValue" />
					</xsl:when>
					<xsl:otherwise>
						<include item="title_fieldValue"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>

			<xsl:with-param name="p_content">
				<include item="typeLink">
					<parameter>
						<xsl:apply-templates select="/document/reference/returns[1]" mode="link">
							<xsl:with-param name="qualified" select="true()" />
						</xsl:apply-templates>
					</parameter>
				</include>
				<br />
				<xsl:apply-templates/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="returns" name="t_returns">
		<xsl:call-template name="t_putSubSection">
			<xsl:with-param name="p_title">
				<include item="title_methodValue"/>
			</xsl:with-param>
			<xsl:with-param name="p_content">
				<include item="typeLink">
					<parameter>
						<xsl:apply-templates select="/document/reference/returns[1]" mode="link">
							<xsl:with-param name="qualified" select="true()" />
						</xsl:apply-templates>
					</parameter>
				</include>
				<br />
				<xsl:apply-templates/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="remarks" name="t_remarks">
		<xsl:call-template name="t_putSectionInclude">
			<xsl:with-param name="p_titleInclude" select="'title_remarks'"/>
			<xsl:with-param name="p_content">
				<xsl:apply-templates/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="example" name="t_example">
		<xsl:call-template name="t_putSectionInclude">
			<xsl:with-param name="p_titleInclude" select="'title_examples'"/>
			<xsl:with-param name="p_content">
				<xsl:apply-templates/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="code" name="t_code">
		<xsl:variable name="v_codeLang">
			<xsl:call-template name="t_codeLang">
				<xsl:with-param name="p_codeLang" select="@language" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="t_putCodeSection">
			<xsl:with-param name="p_codeLang" select="$v_codeLang" />
		</xsl:call-template>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template match="syntax" name="t_syntax">
		<xsl:if test="count(*) > 0">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_syntax'"/>
				<xsl:with-param name="p_content">
					<xsl:call-template name="t_putCodeSections">
						<xsl:with-param name="p_codeNodes" select="./div[@codeLanguage]"/>
						<xsl:with-param name="p_nodeCount" select="count(./div[@codeLanguage])"/>
						<xsl:with-param name="p_codeLangAttr" select="'codeLanguage'"/>
					</xsl:call-template>

					<!-- Parameters & return value -->
					<xsl:apply-templates select="/document/reference/parameters"/>
					<xsl:apply-templates select="/document/reference/templates"/>
					<xsl:choose>
						<xsl:when test="/document/comments/value | /document/comments/returns">
							<xsl:apply-templates select="/document/comments/value" />
							<xsl:apply-templates select="/document/comments/returns" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="/document/reference/returns[1] | /document/reference/eventhandler/type">
								<xsl:call-template name="defaultReturnSection" />
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates select="/document/reference/implements"/>

					<!-- Usage note for extension methods -->
					<xsl:if test="/document/reference/attributes/attribute/type[@api='T:System.Runtime.CompilerServices.ExtensionAttribute'] and boolean($g_apiSubGroup='method')">
						<xsl:call-template name="t_putSubSection">
							<xsl:with-param name="p_title">
								<include item="title_extensionUsage"/>
							</xsl:with-param>
							<xsl:with-param name="p_content">
								<include item="text_extensionUsage">
									<parameter>
										<xsl:apply-templates select="/document/reference/parameters/parameter[1]/type" mode="link"/>
									</parameter>
								</include>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="defaultReturnSection">
		<xsl:call-template name="t_putSubSection">
			<xsl:with-param name="p_title">
				<xsl:choose>
					<xsl:when test="/document/reference/apidata[@subgroup='property']">
						<include item="title_propertyValue" />
					</xsl:when>
					<xsl:when test="/document/reference/apidata[@subgroup='field']">
						<include item="title_fieldValue" />
					</xsl:when>
					<xsl:when test="/document/reference/apidata[@subgroup='event']">
						<include item="title_value" />
					</xsl:when>
					<xsl:otherwise>
						<include item="title_methodValue" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="p_content">
				<include item="typeLink">
					<parameter>
						<xsl:choose>
							<xsl:when test="/document/reference/attributes/attribute/type[@api='T:System.Runtime.CompilerServices.FixedBufferAttribute']">
								<xsl:apply-templates select="/document/reference/attributes/attribute/type[@api='T:System.Runtime.CompilerServices.FixedBufferAttribute']/../argument/typeValue/type" mode="link">
									<xsl:with-param name="qualified" select="true()" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="/document/reference/apidata[@subgroup='event']">
								<xsl:apply-templates select="/document/reference/eventhandler/type" mode="link">
									<xsl:with-param name="qualified" select="true()" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="/document/reference/returns[1]" mode="link">
									<xsl:with-param name="qualified" select="true()" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</parameter>
				</include>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template match="overloads" mode="summary" name="t_overloadsSummary">
		<xsl:choose>
			<xsl:when test="count(summary) > 0">
				<xsl:apply-templates select="summary"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#xa;</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>&#xa;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="overloads" mode="sections" name="t_overloadsSections">
		<xsl:apply-templates select="remarks"/>
		<xsl:apply-templates select="example"/>
	</xsl:template>

	<xsl:template match="templates" name="t_templates">
		<xsl:call-template name="t_putSubSection">
			<xsl:with-param name="p_title">
				<include item="title_templates"/>
			</xsl:with-param>
			<xsl:with-param name="p_content">
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>&#160;</xsl:text>
				<dl>
					<xsl:for-each select="template">
						<xsl:variable name="templateName" select="@name"/>
						<dt>
								<xsl:value-of select="$templateName"/>
						</dt>
						<xsl:text>&#xa;</xsl:text>
						<dd>
							<xsl:apply-templates select="/document/comments/typeparam[@name=$templateName]"/>
						</dd>
						<xsl:text>&#xa;</xsl:text>
					</xsl:for-each>
				</dl>
				<xsl:text>&#160;</xsl:text>
				<xsl:text>&#xa;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template name="t_events">
		<xsl:if test="count(/document/comments/event) &gt; 0">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_events'"/>
				<xsl:with-param name="p_content">
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>&#160;</xsl:text>
					<table>
						<tr>
							<th>
								<include item="header_eventType"/>
							</th>
							<th>
								<include item="header_eventReason"/>
							</th>
						</tr>
						<xsl:for-each select="/document/comments/event">
							<tr>
                <td markdown="span">
									<referenceLink target="{@cref}" qualified="true"/>
								</td>
                <td markdown="span">
									<xsl:apply-templates select="."/>
								</td>
							</tr>
						</xsl:for-each>
					</table>
					<xsl:text>&#160;</xsl:text>
					<xsl:text>&#xa;</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="t_exceptions">
		<xsl:if test="count(/document/comments/exception) &gt; 0">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_exceptions'"/>
				<xsl:with-param name="p_content">
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>&#160;</xsl:text>
					<table>
						<tr>
							<th>
								<include item="header_exceptionName"/>
							</th>
							<th>
								<include item="header_exceptionCondition"/>
							</th>
						</tr>
						<xsl:for-each select="/document/comments/exception">
							<tr>
                <td markdown="span">
									<referenceLink target="{@cref}" qualified="false"/>
								</td>
                <td markdown="span">
									<xsl:apply-templates select="."/>
								</td>
							</tr>
						</xsl:for-each>
					</table>
					<xsl:text>&#160;</xsl:text>
					<xsl:text>&#xa;</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="threadsafety" name="t_threadsafety">
		<xsl:call-template name="t_putSectionInclude">
			<xsl:with-param name="p_titleInclude" select="'title_threadSafety'"/>
			<xsl:with-param name="p_content">
				<xsl:choose>
					<xsl:when test="normalize-space(.)">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:when test="(not(@instance) and not(@static)) or (@static='true' and @instance='false')">
						<include item="boilerplate_threadSafety" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="@static='true'">
							<include item="text_staticThreadSafe"/>
						</xsl:if>
						<xsl:if test="@static='false'">
							<include item="text_staticNotThreadSafe"/>
						</xsl:if>
						<xsl:if test="@instance='true'">
							<include item="text_instanceThreadSafe"/>
						</xsl:if>
						<xsl:if test="@instance='false'">
							<include item="text_instanceNotThreadSafe"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="t_permissions">
		<xsl:if test="count(/document/comments/permission) &gt; 0">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_permissions'"/>
				<xsl:with-param name="p_content">
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>&#160;</xsl:text>
					<table>
						<tr>
							<th>
								<include item="header_permissionName"/>
							</th>
							<th>
								<include item="header_permissionDescription"/>
							</th>
						</tr>
						<xsl:for-each select="/document/comments/permission">
							<tr>
                <td markdown="span">
									<referenceLink target="{@cref}" qualified="true"/>
								</td>
                <td markdown="span">
									<xsl:apply-templates select="."/>
								</td>
							</tr>
						</xsl:for-each>
					</table>
					<xsl:text>&#160;</xsl:text>
					<xsl:text>&#xa;</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template name="t_contracts">
		<xsl:variable name="v_requires" select="/document/comments/requires"/>
		<xsl:variable name="v_ensures" select="/document/comments/ensures"/>
		<xsl:variable name="v_ensuresOnThrow" select="/document/comments/ensuresOnThrow"/>
		<xsl:variable name="v_invariants" select="/document/comments/invariant"/>
		<xsl:variable name="v_setter" select="/document/comments/setter"/>
		<xsl:variable name="v_getter" select="/document/comments/getter"/>
		<xsl:variable name="v_pure" select="/document/comments/pure"/>
		<xsl:if test="$v_requires or $v_ensures or $v_ensuresOnThrow or $v_invariants or $v_setter or $v_getter or $v_pure">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_contracts'"/>
				<xsl:with-param name="p_content">
					<!--Purity-->
					<xsl:if test="$v_pure">
						<xsl:text>&#xa;This method is pure.&#xa;</xsl:text>
					</xsl:if>
					<!--Contracts-->
					<xsl:text>&#xa;</xsl:text>
					<xsl:if test="$v_getter">
						<xsl:variable name="v_getterRequires" select="$v_getter/requires"/>
						<xsl:variable name="v_getterEnsures" select="$v_getter/ensures"/>
						<xsl:variable name="v_getterEnsuresOnThrow" select="$v_getter/ensuresOnThrow"/>
						<xsl:call-template name="t_putSubSection">
							<xsl:with-param name="p_title">
								<include item="title_getter"/>
							</xsl:with-param>
							<xsl:with-param name="p_content">
								<xsl:if test="$v_getterRequires">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_requiresName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_getterRequires"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$v_getterEnsures">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_ensuresName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_getterEnsures"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$v_getterEnsuresOnThrow">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_ensuresOnThrowName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_getterEnsuresOnThrow"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$v_setter">
						<xsl:variable name="v_setterRequires" select="$v_setter/requires"/>
						<xsl:variable name="v_setterEnsures" select="$v_setter/ensures"/>
						<xsl:variable name="v_setterEnsuresOnThrow" select="$v_setter/ensuresOnThrow"/>
						<xsl:call-template name="t_putSubSection">
							<xsl:with-param name="p_title">
								<include item="title_setter"/>
							</xsl:with-param>
							<xsl:with-param name="p_content">
								<xsl:if test="$v_setterRequires">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_requiresName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_setterRequires"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$v_setterEnsures">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_ensuresName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_setterEnsures"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$v_setterEnsuresOnThrow">
									<xsl:call-template name="t_contractsTable">
										<xsl:with-param name="p_title">
											<include item="header_ensuresOnThrowName"/>
										</xsl:with-param>
										<xsl:with-param name="p_contracts" select="$v_setterEnsuresOnThrow"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$v_requires">
						<xsl:call-template name="t_contractsTable">
							<xsl:with-param name="p_title">
								<include item="header_requiresName"/>
							</xsl:with-param>
							<xsl:with-param name="p_contracts" select="$v_requires"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$v_ensures">
						<xsl:call-template name="t_contractsTable">
							<xsl:with-param name="p_title">
								<include item="header_ensuresName"/>
							</xsl:with-param>
							<xsl:with-param name="p_contracts" select="$v_ensures"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$v_ensuresOnThrow">
						<xsl:call-template name="t_contractsTable">
							<xsl:with-param name="p_title">
								<include item="header_ensuresOnThrowName"/>
							</xsl:with-param>
							<xsl:with-param name="p_contracts" select="$v_ensuresOnThrow"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$v_invariants">
						<xsl:call-template name="t_contractsTable">
							<xsl:with-param name="p_title">
								<include item="header_invariantsName"/>
							</xsl:with-param>
							<xsl:with-param name="p_contracts" select="$v_invariants"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:text>&#xa;</xsl:text>
					<!--Contracts link-->
					<a>
						<xsl:attribute name="target">
							<xsl:text>_blank</xsl:text>
						</xsl:attribute>
						<xsl:attribute name="href">
							<xsl:text>http://msdn.microsoft.com/en-us/devlabs/dd491992.aspx</xsl:text>
						</xsl:attribute>
						<xsl:text>Learn more about contracts</xsl:text>
					</a>
					<xsl:text>&#xa;</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="t_contractsTable">
		<xsl:param name="p_title"/>
		<xsl:param name="p_contracts"/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#160;</xsl:text>
		<table>
			<tr>
				<th>
					<xsl:copy-of select="$p_title"/>
				</th>
			</tr>
			<xsl:for-each select="$p_contracts">
				<tr>
          <td markdown="span">
						<div style="margin-bottom: 0pt; white-space: pre-wrap;">
							<pre xml:space="preserve" style="margin-bottom: 0pt"><xsl:value-of select="."/></pre>
						</div>
						<xsl:if test="@description or @inheritedFrom or @exception">
							<div style="font-size:95%; margin-left: 10pt; margin-bottom: 0pt">
								<table>
									<colgroup>
										<col width="10%"/>
										<col width="90%"/>
									</colgroup>
									<xsl:if test="@description">
										<tr style="border-bottom: 0px none;">
											<td style="border-bottom: 0px none;">
												<em><xsl:text>Description: </xsl:text></em>
											</td>
											<td style="border-bottom: 0px none;">
												<xsl:value-of select="@description"/>
											</td>
										</tr>
									</xsl:if>
									<xsl:if test="@inheritedFrom">
										<tr style="border-bottom: 0px none;">
											<td style="border-bottom: 0px none;">
												<em><xsl:text>Inherited From: </xsl:text></em>
											</td>
											<td style="border-bottom: 0px none;">
												<!-- Change the ID type and strip "get_" and "set_" prefixes from property member IDs -->
												<xsl:variable name="inheritedMemberId">
													<xsl:choose>
														<xsl:when test="contains(@inheritedFrom, '.get_')">
															<xsl:value-of select="concat('P:', substring-before(substring(@inheritedFrom, 3), '.get_'), '.', substring-after(@inheritedFrom, '.get_'))"/>
														</xsl:when>
														<xsl:when test="contains(@inheritedFrom, '.set_')">
															<!-- For the setter, we need to strip the last parameter too -->
															<xsl:variable name="lastParam">
																<xsl:call-template name="t_getLastParameter">
																	<xsl:with-param name="p_string" select="@inheritedFrom" />
																</xsl:call-template>
															</xsl:variable>
															<xsl:variable name="setterName">
																<xsl:value-of select="concat('P:', substring-before(substring(@inheritedFrom, 3), '.set_'), '.', substring-after(@inheritedFrom, '.set_'))"/>
															</xsl:variable>
															<xsl:value-of select="concat(substring-before($setterName, $lastParam), ')')"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="@inheritedFrom"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<referenceLink target="{$inheritedMemberId}">
													<xsl:value-of select="@inheritedFromTypeName"/>
												</referenceLink>
											</td>
										</tr>
									</xsl:if>
									<xsl:if test="@exception">
										<tr style="border-bottom: 0px none;">
											<td style="border-bottom: 0px none;">
												<em><xsl:text>Exception: </xsl:text></em>
											</td>
											<td style="border-bottom: 0px none;">
												<referenceLink target="{@exception}" qualified="true"/>
											</td>
										</tr>
									</xsl:if>
								</table>
								<xsl:text>&#160;</xsl:text>
							</div>
						</xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
		<xsl:text>&#160;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<!-- Gets the parameter following the last comma in the given string -->
	<xsl:template name="t_getLastParameter">
		<xsl:param name="p_string" />
		<xsl:choose>
			<xsl:when test="contains($p_string, ',')">
				<xsl:call-template name="t_getLastParameter">
					<xsl:with-param name="p_string" select="substring-after($p_string, ',')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(',', $p_string)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template name="t_putSeeAlsoSection">
		<xsl:if test="$g_hasSeeAlsoSection">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'title_relatedTopics'"/>
				<xsl:with-param name="p_id" select="'seeAlsoSection'"/>
				<xsl:with-param name="p_content">
					<xsl:if test="$g_hasReferenceLinks">
						<xsl:call-template name="t_putSubSection">
							<xsl:with-param name="p_title">
								<include item="title_seeAlso_reference"/>
							</xsl:with-param>
							<xsl:with-param name="p_content">
								<xsl:call-template name="t_autogenSeeAlsoLinks"/>
								<xsl:for-each select="/document/comments//seealso[not(ancestor::overloads) and not(@href)] | /document/reference/elements/element/overloads//seealso[not(@href)]">
									<xsl:apply-templates select=".">
										<xsl:with-param name="displaySeeAlso" select="true()"/>
									</xsl:apply-templates>
									<br />
								</xsl:for-each>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$g_hasOtherResourcesLinks">
						<xsl:call-template name="t_putSubSection">
							<xsl:with-param name="p_title">
								<include item="title_seeAlso_otherResources"/>
							</xsl:with-param>
							<xsl:with-param name="p_content">
								<xsl:for-each select="/document/comments//seealso[not(ancestor::overloads) and @href] | /document/reference/elements/element/overloads//seealso[@href]">
									<xsl:apply-templates select=".">
										<xsl:with-param name="displaySeeAlso" select="true()"/>
									</xsl:apply-templates>
									<br />
								</xsl:for-each>
								<!-- Copy conceptualLink elements as-is -->
								<xsl:for-each select="/document/comments/conceptualLink | /document/reference/elements/element/overloads/conceptualLink">
									<xsl:copy-of select="."/>
									<br />
								</xsl:for-each>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ============================================================================================
	Lists
	============================================================================================= -->

	<xsl:template match="list[@type='bullet' or @type='']" name="t_bulletList">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#160;</xsl:text>
		<ul>
			<xsl:for-each select="item">
				<li>
					<xsl:choose>
						<xsl:when test="term or description">
							<xsl:if test="term">
								<strong>
									<xsl:apply-templates select="term" />
								</strong>
								<xsl:text> - </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="description" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates />
						</xsl:otherwise>
					</xsl:choose>
				</li>
				<xsl:text>&#xa;</xsl:text>
			</xsl:for-each>
		</ul>
		<xsl:text>&#160;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="list[@type='number']" name="t_numberList">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#160;</xsl:text>
		<ol>
			<xsl:if test="@start">
				<xsl:attribute name="start">
					<xsl:value-of select="@start"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="item">
				<xsl:text>&#xa;</xsl:text>
				<li>
					<xsl:choose>
						<xsl:when test="term or description">
							<xsl:if test="term">
								<strong>
									<xsl:apply-templates select="term" />
								</strong>
								<xsl:text> - </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="description" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates />
						</xsl:otherwise>
					</xsl:choose>
				</li>
				<xsl:text>&#xa;</xsl:text>
			</xsl:for-each>
		</ol>
		<xsl:text>&#160;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="list[@type='table']" name="t_tableList">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#160;</xsl:text>
		<table>
			<xsl:for-each select="listheader">
				<tr>
					<xsl:for-each select="*">
						<th>
							<xsl:apply-templates/>
						</th>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
			<xsl:for-each select="item">
				<tr>
					<xsl:for-each select="*">
            <td markdown="span">
							<xsl:apply-templates/>
						</td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</table>
		<xsl:text>&#160;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="list[@type='definition']" name="t_definitionList">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#160;</xsl:text>
		<dl>
			<xsl:for-each select="item">
				<dt>
					<xsl:apply-templates select="term"/>
				</dt>
				<xsl:text>&#xa;</xsl:text>
				<dd>
					<xsl:apply-templates select="description"/>
				</dd>
				<xsl:text>&#xa;</xsl:text>
			</xsl:for-each>
		</dl>
		<xsl:text>&#160;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<!-- ============================================================================================
	Inline tags
	============================================================================================= -->

	<xsl:template match="conceptualLink">
		<xsl:choose>
			<xsl:when test="normalize-space(.)">
				<conceptualLink target="{@target}">
					<xsl:apply-templates/>
				</conceptualLink>
			</xsl:when>
			<xsl:otherwise>
				<conceptualLink target="{@target}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="see[@cref]" name="t_seeCRef">
		<xsl:choose>
			<xsl:when test="starts-with(@cref,'O:')">
				<referenceLink target="{concat('Overload:',substring(@cref,3))}" display-target="format"
					show-parameters="false">
					<xsl:choose>
						<xsl:when test="normalize-space(.)">
							<xsl:value-of select="." />
						</xsl:when>
						<xsl:otherwise>
							<include item="boilerplate_seeAlsoOverloadLink">
								<parameter>{0}</parameter>
							</include>
						</xsl:otherwise>
					</xsl:choose>
				</referenceLink>
			</xsl:when>
			<xsl:when test="normalize-space(.)">
				<referenceLink target="{@cref}">
					<xsl:apply-templates/>
				</referenceLink>
			</xsl:when>
			<xsl:otherwise>
				<referenceLink target="{@cref}" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="see[@href]" name="t_seeHRef">
		<xsl:call-template name="t_hyperlink">
			<xsl:with-param name="p_content" select="."/>
			<xsl:with-param name="p_href" select="@href"/>
			<xsl:with-param name="p_target" select="@target"/>
			<xsl:with-param name="p_alt" select="@alt"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="see[@langword]">
		<xsl:choose>
			<xsl:when test="@langword='null' or @langword='Nothing' or @langword='nullptr'">
				<include item="devlang_nullKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='static' or @langword='Shared'">
				<include item="devlang_staticKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='virtual' or @langword='Overridable'">
				<include item="devlang_virtualKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='true' or @langword='True'">
				<include item="devlang_trueKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='false' or @langword='False'">
				<include item="devlang_falseKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='abstract' or @langword='MustInherit'">
				<include item="devlang_abstractKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='async' or @langword='async'">
				<include item="devlang_asyncKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='await' or @langword='Await' or @langword='let!'">
				<include item="devlang_awaitKeyword"/>
			</xsl:when>
			<xsl:when test="@langword='async/await' or @langword='Async/Await' or @langword='async/let!'">
				<include item="devlang_asyncAwaitKeyword"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>`</xsl:text>
				<xsl:value-of select="@langword" />
				<xsl:text>`</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="seealso[@href]" name="t_seealsoHRef">
		<xsl:param name="displaySeeAlso" select="false()"/>
		<xsl:if test="$displaySeeAlso">
			<xsl:call-template name="t_hyperlink">
				<xsl:with-param name="p_content" select="."/>
				<xsl:with-param name="p_href" select="@href"/>
				<xsl:with-param name="p_target" select="@target"/>
				<xsl:with-param name="p_alt" select="@alt"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="seealso" name="t_seealso">
		<xsl:param name="displaySeeAlso" select="false()"/>
		<xsl:if test="$displaySeeAlso">
			<xsl:choose>
				<xsl:when test="starts-with(@cref,'O:')">
					<referenceLink target="{concat('Overload:',substring(@cref,3))}" display-target="format"
						show-parameters="false">
						<xsl:choose>
							<xsl:when test="normalize-space(.)">
								<xsl:apply-templates />
							</xsl:when>
							<xsl:otherwise>
								<include item="boilerplate_seeAlsoOverloadLink">
									<parameter>{0}</parameter>
								</include>
							</xsl:otherwise>
						</xsl:choose>
					</referenceLink>
				</xsl:when>
				<xsl:when test="normalize-space(.)">
					<referenceLink target="{@cref}" qualified="true">
						<xsl:apply-templates />
					</referenceLink>
				</xsl:when>
				<xsl:otherwise>
					<referenceLink target="{@cref}" qualified="true"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template name="t_hyperlink">
		<xsl:param name="p_content"/>
		<xsl:param name="p_href"/>
		<xsl:param name="p_target"/>
		<xsl:param name="p_alt"/>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="$p_href"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="normalize-space($p_target)">
					<xsl:attribute name="target">
						<xsl:value-of select="normalize-space($p_target)"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="target">_blank</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="normalize-space($p_alt)">
				<xsl:attribute name="title">
					<xsl:value-of select="normalize-space($p_alt)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="normalize-space($p_content)">
					<xsl:value-of select="$p_content"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$p_href"/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template match="note" name="t_note">
		<xsl:call-template name="t_putAlert">
			<xsl:with-param name="p_alertClass" select="@type"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ======================================================================================== -->

	<xsl:template name="t_getParameterDescription">
		<xsl:param name="name"/>
		<xsl:apply-templates select="/document/comments/param[@name=$name]"/>
	</xsl:template>

	<xsl:template name="t_getReturnsDescription">
		<xsl:param name="name"/>
		<xsl:apply-templates select="/document/comments/param[@name=$name]"/>
	</xsl:template>

	<xsl:template name="t_getElementDescription">
		<xsl:apply-templates select="summary[1]"/>
	</xsl:template>

	<xsl:template name="t_getOverloadSummary">
		<xsl:apply-templates select="overloads" mode="summary"/>
	</xsl:template>

	<xsl:template name="t_getOverloadSections">
		<xsl:apply-templates select="overloads" mode="sections"/>
	</xsl:template>

	<!-- ============================================================================================
	Bibliography
	============================================================================================= -->

	<xsl:key name="k_citations" match="//cite" use="text()"/>

	<xsl:variable name="g_hasCitations" select="boolean(count(//cite) > 0)"/>

	<xsl:template match="cite" name="t_cite">
		<xsl:variable name="v_currentCitation" select="text()"/>
		<xsl:for-each select="//cite[generate-id(.)=generate-id(key('k_citations',text()))]">
			<!-- Distinct citations only -->
			<xsl:if test="$v_currentCitation=.">
				<xsl:choose>
					<xsl:when test="document($bibliographyData)/bibliography/reference[@name=$v_currentCitation]">
						<sup>
							<a>
								<xsl:attribute name="href">
									#cite<xsl:value-of select="position()"/>
								</xsl:attribute>\[<xsl:value-of select="position()"/>\]
							</a>
						</sup>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="t_bibliography">
		<xsl:if test="$g_hasCitations">
			<xsl:call-template name="t_putSectionInclude">
				<xsl:with-param name="p_titleInclude" select="'bibliographyTitle'"/>
				<xsl:with-param name="p_content">
					<xsl:call-template name="t_autogenBibliographyLinks"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="t_autogenBibliographyLinks">
		<xsl:for-each select="//cite[generate-id(.)=generate-id(key('k_citations',text()))]">
			<!-- Distinct citations only -->
			<xsl:variable name="citation" select="."/>
			<xsl:variable name="entry" select="document($bibliographyData)/bibliography/reference[@name=$citation]"/>

			<xsl:call-template name="bibliographyReference">
				<xsl:with-param name="number" select="position()"/>
				<xsl:with-param name="data" select="$entry"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Revision History information template processing. -->
	<xsl:template name="t_revisionHistory" match="revisionHistory" >
		<xsl:if test="boolean(count(/document//revisionHistory) > 0)">
			<xsl:if test="not(/document//revisionHistory[@visible='false'])">
				<xsl:call-template name="t_putSectionInclude">
					<xsl:with-param name="p_titleInclude" select="'title_revisionHistory'"/>
					<xsl:with-param name="p_content">
						<xsl:text>&#xa;</xsl:text>
						<xsl:text>&#160;</xsl:text>
						<table>
							<tr>
								<th>
									<include item="header_revHistoryDate" />
								</th>
								<th>
									<include item="header_revHistoryVersion" />
								</th>
								<th>
									<include item="header_revHistoryDescription" />
								</th>
							</tr>
							<xsl:for-each select="/document//revisionHistory/revision">
								<xsl:if test="not(@visible='false')">
									<tr>
										<td markdown="span">
											<xsl:value-of select="@date"/>
										</td>
                    <td markdown="span">
											<xsl:value-of select="@version"/>
										</td>
                    <td markdown="span">
											<xsl:apply-templates />
										</td>
									</tr>
								</xsl:if>
							</xsl:for-each>
						</table>
						<xsl:text>&#160;</xsl:text>
						<xsl:text>&#xa;</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Pass through a chunk of markup.  This will allow build components to add HTML or other elements such as
			 "include" for localized shared content to a pre-transformed document.  This prevents it being removed as
			 unrecognized content by the transformations. -->
	<xsl:template match="markup">
		<xsl:copy-of select="node()"/>
	</xsl:template>
</xsl:stylesheet>
