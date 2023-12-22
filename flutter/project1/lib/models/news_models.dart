import 'package:flutter/material.dart';

class NewsModel {
  String Title;
  String Source;
  String Url;
  String PublishedOn;
  String Description;
  String Image;
  String SourceNationality;
  Map TitleSentiment;
  String Summary;
  List Country;
  List Cities;
  Map Categories;

  NewsModel({
    required this.Title,
    required this.Source,
    required this.Url,
    required this.PublishedOn,
    required this.Description,
    required this.Image,
    required this.SourceNationality,
    required this.TitleSentiment,
    required this.Summary,
    required this.Country,
    required this.Cities,
    required this.Categories,
  });

  List<NewsModel> getNews() {}
}
