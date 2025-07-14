class LoginModel {
  LoginModel({
    String? accessToken,
    String? refreshToken,
    String? id,
    String? name,
    String? email,
    bool? isAdmin,
    bool? firstTime,
    String? lastLogin,
    String? userReommID,
    String? stripeCustomerId,
  }) {
    _accessToken = accessToken;
    _accessToken = accessToken;
    _id = id;
    _name = name;
    _email = email;
    _isAdmin = isAdmin;
    _firstTime = firstTime;
    _lastLogin = lastLogin;
    _stripeCustomerId = stripeCustomerId;
    _userReommID = userReommID;
  }

  LoginModel.fromJson(dynamic json) {
    _accessToken = json['accessToken'];
    _refreshToken = json['refreshToken'];
    _id = json['_id'];
    _name = json['name'];
    _email = json['email'];
    _isAdmin = json['isAdmin'];
    _firstTime = json['firstTime'];
    _lastLogin = json['lastLogin'];
    _stripeCustomerId = json['stripeCustomerId'];
    _userReommID = json['user_id'];
  }

  String? _accessToken;
  String? _refreshToken;
  String? _id;
  String? _name;
  String? _email;
  bool? _isAdmin;
  bool? _firstTime;
  String? _lastLogin;
  String? _stripeCustomerId;
  String? _userReommID;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get id => _id;
  String? get name => _name;
  String? get email => _email;
  bool? get isAdmin => _isAdmin;
  bool? get firstTime => _firstTime;
  String? get lastLogin => _lastLogin;
  String? get stripeCustomerId => _stripeCustomerId;
  String? get userReommID => _userReommID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessToken'] = _accessToken;
    map['refreshToken'] = _refreshToken;
    map['_id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['isAdmin'] = _isAdmin;
    map['firstTime'] = _firstTime;
    map['lastLogin'] = _lastLogin;
    map['stripeCustomerId'] = _stripeCustomerId;
    map['user_id'] = _userReommID;
    return map;
  }
}
