extension MiLista<T> on List<T>{
  List<T> copiar () => [...this];
}

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());
  //bool isNotBlank() => this != null && this.isNotEmpty;
}