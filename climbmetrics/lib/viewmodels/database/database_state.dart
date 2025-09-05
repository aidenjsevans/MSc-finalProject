/// [Enum] describing the various local database states
enum DatabaseState {
  nominal,
  loading,
  initializing,
  closed,
  error,
  terminated
}
