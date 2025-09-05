
/// [Enum] describing the various login states
enum LoginState {
  nominal,
  userNotFound,
  invalidEmail,
  invalidPassword,
  invalidCredential,
  channelError,
  emptyEntry,
  error,
}
