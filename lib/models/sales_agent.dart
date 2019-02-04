class SalesAgent{
  String id;
  String email;
  String password;
  int credits;
  String name;

  SalesAgent(this.id,this.name,this.email,this.password,this.credits);

  SalesAgent.fromJson(dynamic f){
    id = f['id'];
    email = f['email'];
    credits = f['credits'];
    name = f['name'];
  }

  toJson(){
    return{
      'id':id,
      'email':email,
      'credits':credits,
      'name':name
    };
  }
}