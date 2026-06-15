import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';

class MapWebviewScreen extends StatefulWidget {
  final String url;
  final String title;

  const MapWebviewScreen({
    super.key,
    required this.url,
    this.title = 'Peta Pakar Terdekat',
  });

  @override
  State<MapWebviewScreen> createState() => _MapWebviewScreenState();
}

class _MapWebviewScreenState extends State<MapWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('Navigating to: $url');
            
            // Tangani skema intent:// khusus Android (alihan native Google Maps)
            if (url.toLowerCase().startsWith('intent:')) {
              var webUrl = url;
              if (webUrl.startsWith('intent://')) {
                webUrl = webUrl.replaceFirst('intent://', 'https://');
              } else if (webUrl.startsWith('intent:')) {
                webUrl = webUrl.replaceFirst('intent:', 'https:');
              }
              
              final intentIndex = webUrl.indexOf('#Intent;');
              if (intentIndex != -1) {
                webUrl = webUrl.substring(0, intentIndex);
              }
              
              try {
                final Uri uri = Uri.parse(webUrl);
                launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                  debugPrint('Gagal membuka url intent secara eksternal: $e');
                  return false;
                });
              } catch (e) {
                debugPrint('Gagal memproses URL intent: $e');
              }
              return NavigationDecision.prevent;
            }

            // Tangani skema eksternal non http/https lainnya (seperti geo:, whatsapp:, dll.)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              try {
                final Uri uri = Uri.parse(url);
                launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                  debugPrint('Gagal membuka skema eksternal secara eksternal: $e');
                  return false;
                });
              } catch (e) {
                debugPrint('Gagal memproses skema eksternal: $e');
              }
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    
    final scaffoldBgColor = isDarkBg ? const Color(0xFF090715) : const Color(0xFFF8F9FD);
    final appBarBgColor = isDarkBg ? const Color(0xFF16162D) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        title: Text(
          widget.title, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            } else {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
        ],
      ),
    );
  }
}
