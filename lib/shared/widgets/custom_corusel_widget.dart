import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> images;

   const ImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CarouselSlider(
        options: CarouselOptions(
          height:  MediaQuery.of(context).size.height * 0.3, // Height of the carousel
          autoPlay: true, // Enable auto-scrolling
          enlargeCenterPage: true, // Enlarges the center image
          aspectRatio: 16 / 9, // Aspect ratio for images
          autoPlayInterval: const Duration(seconds: 3), // Delay between slides
        ),
        items: images.map((imagePath) {
          return Builder(
            builder: (BuildContext context) {
              return  Container(
                margin:  const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}