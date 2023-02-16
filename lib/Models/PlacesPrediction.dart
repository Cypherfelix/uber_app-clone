/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class MainTextMatchedSubstring {
  int length;
  int offset;

  MainTextMatchedSubstring({this.length, this.offset});

  MainTextMatchedSubstring.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['length'] = length;
    data['offset'] = offset;
    return data;
  }
}

class MatchedSubstring {
  int length;
  int offset;

  MatchedSubstring({this.length, this.offset});

  MatchedSubstring.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['length'] = length;
    data['offset'] = offset;
    return data;
  }
}

class Prediction {
  String description;
  List<MatchedSubstring> matchedsubstrings;
  String placeid;
  String reference;
  StructuredFormatting structuredformatting;
  List<Term> terms;
  List<String> types;

  Prediction(
      {this.description,
      this.matchedsubstrings,
      this.placeid,
      this.reference,
      this.structuredformatting,
      this.terms,
      this.types});

  Prediction.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    if (json['matched_substrings'] != null) {
      matchedsubstrings = <MatchedSubstring>[];
      json['matched_substrings'].forEach((v) {
        matchedsubstrings.add(MatchedSubstring.fromJson(v));
      });
    }
    placeid = json['place_id'];
    reference = json['reference'];
    structuredformatting = json['structured_formatting'] != null
        ? StructuredFormatting?.fromJson(json['structured_formatting'])
        : null;
    if (json['terms'] != null) {
      terms = <Term>[];
      json['terms'].forEach((v) {
        terms.add(Term.fromJson(v));
      });
    }
    if (json['types'] != null) {
      types = <String>[];
      json['types'].forEach((v) {
        types.add(v.toString());
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['description'] = description;
    data['matched_substrings'] = matchedsubstrings != null
        ? matchedsubstrings.map((v) => v?.toJson()).toList()
        : null;
    data['place_id'] = placeid;
    data['reference'] = reference;
    data['structured_formatting'] = structuredformatting.toJson();
    data['terms'] =
        terms != null ? terms.map((v) => v?.toJson()).toList() : null;
    data['types'] =
        types != null ? types.map((v) => v?.toString()).toList() : null;
    return data;
  }
}

class Root {
  List<Prediction> predictions;

  Root({this.predictions});

  Root.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Prediction>[];
      json['predictions'].forEach((v) {
        predictions.add(Prediction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['predictions'] = predictions != null
        ? predictions.map((v) => v?.toJson()).toList()
        : null;
    return data;
  }
}

class StructuredFormatting {
  String maintext;
  List<MainTextMatchedSubstring> maintextmatchedsubstrings;
  String secondarytext;

  StructuredFormatting(
      {this.maintext, this.maintextmatchedsubstrings, this.secondarytext});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    maintext = json['main_text'];
    if (json['main_text_matched_substrings'] != null) {
      maintextmatchedsubstrings = <MainTextMatchedSubstring>[];
      json['main_text_matched_substrings'].forEach((v) {
        maintextmatchedsubstrings.add(MainTextMatchedSubstring.fromJson(v));
      });
    }
    secondarytext = json['secondary_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['main_text'] = maintext;
    data['main_text_matched_substrings'] = maintextmatchedsubstrings != null
        ? maintextmatchedsubstrings.map((v) => v?.toJson()).toList()
        : null;
    data['secondary_text'] = secondarytext;
    return data;
  }
}

class Term {
  int offset;
  String value;

  Term({this.offset, this.value});

  Term.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['offset'] = offset;
    data['value'] = value;
    return data;
  }
}
