struct Logger {
  static func log(_ message: String) {
#if DEBUG
    print("[SolicitReviewLibrary] \(message)")
#endif
  }
}
