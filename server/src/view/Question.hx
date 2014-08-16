package view;

@:includeTemplate('question.html')
class Question extends erazor.macro.SimpleTemplate<{ question:db.Question }>
{
}

