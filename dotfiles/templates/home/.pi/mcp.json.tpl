{
	"servers": [
		{
			"name": "karpathy-wiki",
			"transport": "http",
			"url": "https://karpathy-wiki-mcp-server.mars.${COMPANY_DOMAIN}/mcp"
		},
		{
			"name": "KafkaMCPServer",
			"transport": "sse",
			"url": "https://kafka-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "JiraMCPServer",
			"transport": "sse",
			"url": "https://jira-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "PandoraQAMCPServer",
			"transport": "sse",
			"url": "https://qa-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "TBPMCPServer",
			"transport": "sse",
			"url": "https://tbp-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "SonarMCPServer",
			"transport": "sse",
			"url": "https://sonar-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "PandoraMCPServer",
			"transport": "sse",
			"url": "https://pandora-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "GitlabMCPServer",
			"transport": "sse",
			"url": "https://gitlab-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "AresMCPServer",
			"transport": "sse",
			"url": "https://ares-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "OpenApiMCPServer",
			"transport": "sse",
			"url": "https://open-api-mcp-server.stage.${COMPANY_DOMAIN}/sse"
		},
		{
			"name": "BeholderMCPServer",
			"transport": "sse",
			"url": "https://beholder-mcp-server.mars.${COMPANY_DOMAIN}/sse"
		}
	]
}
