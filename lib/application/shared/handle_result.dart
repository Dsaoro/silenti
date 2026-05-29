class HandleResult<T> {
  late bool status;
  late String message;
  late T model;

  void setError(String userMessage) {
    status = false;
    message = userMessage;
  }

  void setData(T model, [String userMessage = '']) {
    status = true;
    this.model = model;

    if (userMessage.isEmpty) {
      message = '';
    }

    message = userMessage;
  }
}
