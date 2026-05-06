import 'package:Box4Pets/config/app_color.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_storage/get_storage.dart';

import 'components/custom_carousel_indicator.dart';

class BaseSlider extends StatefulWidget {
  const BaseSlider({Key? key}) : super(key: key);

  @override
  _BaseSliderState createState() => _BaseSliderState();
}

class _BaseSliderState extends State<BaseSlider> {
  final box = GetStorage();
  CarouselSliderController buttonCarouselController = CarouselSliderController();
  int _currentIndex = 0;
  List<Widget> listCarousel = [
    Container(
      color: AppColor.primary,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/cachorro1_solto 1.png'),
            const Text(
              textAlign: TextAlign.center,
              'Bem vindo!',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 36),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              textAlign: TextAlign.center,
              'Garanta mais qualidade de \n vida para seu Pet',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 21),
            ),
          ],
        ),
      ),
    ),
    Container(
      padding: const EdgeInsets.only(top: 80),
      color: AppColor.secondary,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/tela2_solto 1.png', fit: BoxFit.fill),
            Text(
              textAlign: TextAlign.center,
              'Tecnologia',
              style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 36),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              textAlign: TextAlign.center,
              'Um teste genético completo \n na palma da sua mão',
              style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 21),
            ),
          ],
        ),
      ),
    ),
    Container(
      padding: const EdgeInsets.only(top: 80),
      color: AppColor.orange,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Image.asset('assets/images/tela4_solto 1.png',
                  fit: BoxFit.fill),
            ),
            const Text(
              textAlign: TextAlign.center,
              'Resultado',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 36),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              textAlign: TextAlign.center,
              'Simples e eficaz para tutores, \n veterinários e criadores',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 21),
            ),
          ],
        ),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              CarouselSlider(
                carouselController: buttonCarouselController,
                options: CarouselOptions(
                  height:
                      MediaQuery.of(context).size.height, // Fullscreen height
                  viewportFraction: 1.0,
                  // Take up the whole screen width
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: listCarousel,
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width * .40,
            child: CustomCarouselIndicator(
              itemCount: listCarousel.length,
              currentIndex: _currentIndex,
            ),
          ),
          Positioned(
              bottom: 50,
              right: 25,
              child: InkWell(
                onTap: () {
                  box.write('firstAccess', true);
                  _currentIndex == 2
                      ? Navigator.popAndPushNamed(context, '/login')
                      : buttonCarouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                },
                child: Container(
                  width: 60,
                  height: 61,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.4),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
