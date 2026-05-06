// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Box4Pets/config/app_color.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class SideMenu extends StatefulWidget {
  final void Function() callback;
  const SideMenu({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String _authStatus = 'Unknown';
  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');

    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));

      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    } else if (status == TrackingStatus.authorized) {
      _launchUrl('https://box4pets.com.br/collections/frontpage');
    } else if (status == TrackingStatus.denied) {
      _launchUrl('https://box4pets.com.br/collections/frontpage');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUrl(String url) async {
    return showDialog(
      context: context,
      builder: (context) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) async {
                if (request.url
                    .startsWith('https://api.whatsapp.com/send?phone')) {
                  const phone = "5512992111805";
                  const message = 'Olá!';
                  await _launchURL(
                      "https://wa.me/$phone/?text=${Uri.parse(message)}");
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url));

        return Scaffold(
          appBar: AppBar(
              title: Text("Navegação Box4Pets"),
              backgroundColor: AppColor.primary),
          body: WebViewWidget(controller: controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary.withOpacity(.5),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(100))),
          width: 288,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logoB4p_branco.png'),
                    const Spacer(),
                    IconButton(
                        onPressed: widget.callback,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    WidgetsFlutterBinding.ensureInitialized()
                        .addPostFrameCallback((_) => initPlugin());

                    // showCustomTrackingDialog(context);
                    // final TrackingStatus status = await AppTrackingTransparency
                    //     .requestTrackingAuthorization();

                    _launchUrl('https://box4pets.com.br/collections/frontpage');
                  },
                  child: const ListTile(
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Adquirir',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/activation'),
                  child: const ListTile(
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(
                        Icons.download_done_sharp,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Ativar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () =>
                      _launchURL('https://wa.me/message/XIRC4QVE57Y7H1'),
                  child: const ListTile(
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Fale conosco',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () => _launchURL(
                      'https://calendly.com/contato-box4pets/30min?month=2023-08'),
                  child: const ListTile(
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(
                        Icons.question_mark,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Dúvidas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () => _launchURL(
                      'https://filtrobox4pets.netlify.app/doencas/caes'),
                  child: const ListTile(
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(
                        Icons.filter_alt_sharp,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Pesquise doenças e traços',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _launchUrl("https://www.instagram.com/box4petsdna/");
                      },
                      child: FaIcon(
                        FontAwesomeIcons.instagram,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _launchUrl("https://www.facebook.com/box4petsdna");
                      },
                      child: FaIcon(
                        FontAwesomeIcons.facebook,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _launchUrl("https://br.linkedin.com/company/box4pets");
                      },
                      child: FaIcon(
                        FontAwesomeIcons.linkedin,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _launchUrl(
                            "https://www.youtube.com/channel/UCIDCrppUg2BxuGlcykB3D3A");
                      },
                      child: FaIcon(
                        FontAwesomeIcons.youtube,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
