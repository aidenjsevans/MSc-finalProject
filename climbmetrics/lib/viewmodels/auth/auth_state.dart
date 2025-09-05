/// [Enum] describing the various authentication states
enum AuthState {
  loggedOut, 
  loggedIn,
  emailNotVerified,
  verifying,
  loading,
  nominal,
  initializing,
  error
}
