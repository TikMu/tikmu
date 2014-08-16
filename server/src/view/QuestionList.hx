package view;

@:includeTemplate('qlist.html')
class QuestionList extends erazor.macro.SimpleTemplate<{ question:db.Question }>
{
}
