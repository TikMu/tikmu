package js;
import croxit.js.Client;

@:expose @:keep
class Functions
{
	public static function run() 
	{
		Client.onDeviceReady(function() {			
			
		});
	}
	
	public static function confirmDeleteQuestion(questionID : String)
	{
		if (questionID != '' && Browser.window.confirm('Tem certeza que deseja deletar essa questão?'))
			Browser.location.href = '/deletequestion/' + questionID;
	}
	
	public static function confirmDeleteAnswer(questionID : String, answerIndex : Int)
	{
		if (questionID != '' && answerIndex > 0 && Browser.window.confirm('Tem certeza que deseja deletar essa resposta?'))
			Browser.location.href = '/deleteanswer/' + questionID + '/' + answerIndex;
	}
	
	public static function confirmDeleteComment(questionID : String, ?answerIndex : Int, commentIndex : Int)
	{
		if (questionID != '' && (answerIndex == null || answerIndex > 0) && (commentIndex > 0) && Browser.window.confirm('Tem certeza que deseja deletar essa resposta?'))
			Browser.location.href = '/deletecomment/' + questionID + '/' + answerIndex + '/' + commentIndex;
	}
	
	public static function markQuestionAsSolved(questionID : String)
	{
		if(questionID != '')
			Browser.location.href = '/markquestionassolved/' + questionID;
	}
	
	public static function voteUp(questionID : String, ?answerIndex : Int)
	{
		if(questionID != '' && (answerIndex == null || answerIndex > 0))
			Browser.location.href = '/voteup/' + questionID + ((answerIndex != null) ? '/' + answerIndex : '');
	}
	
	public static function voteDown(questionID : String, ?answerIndex : Int)
	{
		if(questionID != '' && (answerIndex == null || answerIndex > 0))
			Browser.location.href = '/votedown/' + questionID + ((answerIndex != null) ? '/' + answerIndex : '');
	}
	
	public static function toggleFav(questionID : String)
	{
		if (questionID != '')
			Browser.location.href = '/togglefavorite/' + questionID;
	}
	
	public static function toggleFollow(questionID : String)
	{
		if (questionID != '')
			Browser.location.href = '/togglefollow/' + questionID;
	}
}