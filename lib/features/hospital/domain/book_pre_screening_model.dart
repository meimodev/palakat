// TODO for slicing purposes only
class BookPreScreeningModel {
  String question;
  bool correctAnswer;
  bool? answer;

  BookPreScreeningModel({
    required this.question,
    required this.correctAnswer,
    this.answer,
  });
}
