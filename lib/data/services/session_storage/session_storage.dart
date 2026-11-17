import 'session_storage_base.dart';
import 'session_storage_stub.dart'
    if (dart.library.html) 'session_storage_web.dart';

export 'session_storage_base.dart';

/// Factory returning platform-appropriate session storage (Web sessionStorage or VM in-memory).
SessionStorage createSessionStorage() => getSessionStorage();
