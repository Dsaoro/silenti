class HandleResult<T> {
  bool status = false;
  String message = "";
  T? model;

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
