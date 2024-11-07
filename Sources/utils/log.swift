import BaseKit

#if NETKIT_DEBUG
/// Internal logger instance.
let _log = Log(mode: .console, prefix: "[🚐]")
#else
let _log = Log(mode: .none)
#endif
