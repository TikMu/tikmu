package view;

@:includeTemplate('questionlist.html')
class QuestionList extends erazor.macro.SimpleTemplate<{ question:db.Question, nextUrl:String, lastUrl:String }>
{
}
