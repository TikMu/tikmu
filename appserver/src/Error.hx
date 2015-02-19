import db.Session;

enum AuthenticationError {
}

enum AuthorizationError {
	NotLogged;
	ExpiredSession(s:Session);
}

