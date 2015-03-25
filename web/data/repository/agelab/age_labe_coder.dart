part of visualizer;


class AgeLabCoders extends DataCoders {
  AgeLabCoders() {
  }
  List<DataCoder> getValidCoders(){
    return [
        new AgeLabCoder("I am a DAVID open source user",1)
    ];
  }
}

class AgeLabCoder extends DataCoder {
  String name;
  int id;

  AgeLabCoder(this.name,this.id) {
  }

  bool isValid(){
    return true;
  }
}
