import BaseKit

#if UXKIT_DEBUG
let _log = Log(mode: .unified, prefix: "[🚐]")
#else
let _log = Log(mode: .none)
#endif
