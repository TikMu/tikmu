package db;
import db.helper.*;
import org.bsonspec.*;
import crypto.Password;

typedef User = {
	_id : ObjectID,
	name : String,
	email : String,
	password : Password,
	avatar : String,
	points : Int,
	//LinkParaContaSocial
	//Linguagem de Preferência
	//Formas de Notificação
	//Área de Notificação
}
