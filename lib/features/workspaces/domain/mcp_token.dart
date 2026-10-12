/// A token an MCP client (an AI assistant) connects to one server garden
/// with. The secret itself is only known right after creation
/// ([CreatedMcpToken]); listings show [tokenPrefix] to tell tokens apart.
class McpToken {
  final String id;
  final String name;
  final String tokenPrefix;

  /// Whether the assistant may change the garden, not only read it.
  final bool canWrite;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  /// The member who created it (the owner also sees everyone else's).
  final String? email;

  const McpToken({
    required this.id,
    required this.name,
    required this.tokenPrefix,
    required this.canWrite,
    required this.createdAt,
    this.lastUsedAt,
    this.email,
  });

  factory McpToken.fromJson(Map<String, dynamic> json) => McpToken(
        id: json['id'] as String,
        name: json['name'] as String,
        tokenPrefix: json['tokenPrefix'] as String,
        canWrite: json['canWrite'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] == null
            ? null
            : DateTime.parse(json['lastUsedAt'] as String),
        email: json['email'] as String?,
      );
}

/// A token just created, with its secret.
typedef CreatedMcpToken = ({McpToken token, String secret});

/// The MCP endpoint of a server, for the client's configuration.
String mcpEndpoint(String serverUrl) => '$serverUrl/api/v1/mcp';
