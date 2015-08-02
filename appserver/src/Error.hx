import db.Session;

enum AuthenticationError {
// common:
	EInvalidEmail;
	EInvalidPass;

// registration only:
	EInvalidName;
	EUserAlreadyExists;

// login only:
	EFailedLogin;  // wrong email, pass, token, etc.
}

enum AuthorizationError {
	NotLogged;
	ExpiredSession(s:Session);
}

enum NotificationError {
	ENoMatchingNotification(url:String);
}

