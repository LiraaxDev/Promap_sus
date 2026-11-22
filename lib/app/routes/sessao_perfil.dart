enum PerfilUsuario { acs, cidadao }

/// Perfil ativo na sessão (ACS = Perfil Macro de campo; Cidadão = Perfil Micro).
class SessaoPerfil {
  const SessaoPerfil._();

  static PerfilUsuario? atual;
}
