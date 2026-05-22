class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.authenticated() => const AuthResult._(success: true);

  factory AuthResult.invalidCredentials() => const AuthResult._(
        success: false,
        errorMessage: 'Email ou senha incorretos!',
      );

  factory AuthResult.apiUnauthorized() => const AuthResult._(
        success: false,
        errorMessage:
            'Não foi possível conectar ao servidor. Verifique o token Airtable no arquivo .env.',
      );

  factory AuthResult.networkError() => const AuthResult._(
        success: false,
        errorMessage: 'Erro de conexão. Verifique sua internet e tente novamente.',
      );
}
