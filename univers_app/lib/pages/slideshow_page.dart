import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:univers_app/integrations/supabase_service.dart';
import 'package:univers_app/models/univers_asset_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/widgets/hold_button.dart';
import 'package:univers_app/globals/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

@NowaGenerated()
class SlideshowPage extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SlideshowPage({required this.univers, super.key});

  final UniversModel univers;

  @override
  State<SlideshowPage> createState() {
    return _SlideshowPageState();
  }
}

@NowaGenerated()
class _SlideshowPageState extends State<SlideshowPage> {
  int currentIndex = 0;

  bool isMuted = false;

  bool isPlayingVideo = false;

  late PageController pageController;

  VideoPlayerController? videoPlayerController;

  ChewieController? chewieController;

  AudioPlayer? audioPlayer;

  FlutterTts? _tts;

  late String universId;

  late String slug;

  // Voix préférées par langue pour un son plus naturel
  final Map<String, String> preferredVoices = {
    'fr': 'Amélie',
    'en': 'Samantha',
    'es': 'Paulina',
    'de': 'Anna',
    'it': 'Alice',
    // Le mécanisme dynamique détecte automatiquement les nouvelles langues
  };

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    universId = widget.univers.id ?? '';
    slug = widget.univers.slug ?? '';

    _initTts();

    audioPlayer = AudioPlayer();
    final musicUrl =
        'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/$slug/music.mp3';
    audioPlayer?.play(UrlSource(musicUrl));
    SupabaseService().preloadUniversAssets(slug);
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts?.setLanguage('fr'); // Langue par défaut, à adapter avec appState
    await _tts?.setSpeechRate(0.4); // Plus lent pour un son plus naturel
    await _tts?.setPitch(1.0); // Hauteur normale
    await _tts?.setVolume(1.0); // Volume max
  }

  @override
  void dispose() {
    pageController.dispose();
    videoPlayerController?.dispose();
    chewieController?.dispose();
    audioPlayer?.dispose();
    _tts?.stop();
    super.dispose();
  }

  void stopVideo() {
    setState(() {
      isPlayingVideo = false;
      videoPlayerController?.pause();
      videoPlayerController?.dispose();
      chewieController?.dispose();
      videoPlayerController = null;
      chewieController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5e6d3),
      body: SafeArea(
        child: DataBuilder<List<UniversAssetModel>>(
          future: SupabaseService().getUniversAssets(universId),
          loadingWidget: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
              color: Colors.white,
            ),
          ),
          errorBuilder: (context, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80.0, color: Colors.red),
                const SizedBox(height: 20.0),
                const Text(
                  'Oups ! Une erreur est survenue',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          builder: (context, assets) {
            if (assets.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune image disponible',
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                ),
              );
            }
            return Stack(
              children: [
                // Layout principal : image OU vidéo (jamais superposés)
                Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isPlayingVideo && chewieController != null
                            ? GestureDetector(
                                key: const ValueKey('video'),
                                onTap: stopVideo,
                                child: Container(
                                  color: const Color(0xfff5e6d3), // Même fond que l'image
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: videoPlayerController!.value.aspectRatio,
                                      child: Chewie(controller: chewieController!),
                                    ),
                                  ),
                                ),
                              )
                            : PageView.builder(
                                key: const ValueKey('pageview'),
                                controller: pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                  _speakCurrentTitle(assets);
                                },
                                itemCount: assets.length,
                                itemBuilder: (context, index) {
                                  final asset = assets[index];
                                  final encodedFolder = Uri.encodeComponent(slug);
                                  final encodedImage = Uri.encodeComponent(
                                    asset.imageUrl ?? '',
                                  );
                                  final imageUrl =
                                      'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/$encodedFolder/$encodedImage';

                                  return GestureDetector(
                                    onTap: () {
                                      final videoExtension = kIsWeb
                                          ? '_silent.webm'
                                          : '_silent.mp4';
                                      final videoName =
                                          asset.imageUrl?.replaceAll(
                                            '.png',
                                            videoExtension,
                                          ) ??
                                          '';
                                      final encodedVideo = Uri.encodeComponent(
                                        videoName,
                                      );
                                      String videoUrl =
                                          asset.animationUrl ??
                                          'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/${Uri.encodeComponent(slug)}/${encodedVideo}';

                                      playVideo(videoUrl);
                                    },
                                    child: Container(
                                      color: const Color(0xfff5e6d3), // Fond uniforme
                                      child: Center(
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: kIsWeb ? BoxFit.contain : BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 100.0,
                                                color: Colors.grey,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Texte en bas (toujours visible, même couleur)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 20.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xfff5e6d3), // Fond uniforme
                      ),
                      child: Text(
                        assets[currentIndex].translations?[Provider.of<AppState>(context).selectedLanguage] ??
                        assets[currentIndex].title ?? '',
                        style: const TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Toujours noir
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Boutons superposés (inchangés)
                Positioned(
                  top: 20.0,
                  left: 20.0,
                  child: HoldButton(
                    iconBuilder: () => Icons.arrow_back_rounded,
                    onHold: () {
                      Navigator.pop(context);
                    },
                    gradientColors: const [
                      Color(0xFFFF6B9D),
                      Color(0xFFFF8CAB),
                    ],
                    size: 70.0,
                    iconSize: 40.0,
                    holdDuration: const Duration(seconds: 2),
                  ),
                ),

                if (kIsWeb)
                  Positioned(
                    left: 20.0,
                    top: MediaQuery.of(context).size.height / 2 - 35,
                    child: HoldButton(
                      iconBuilder: () => Icons.arrow_back_ios_new_rounded,
                      onHold: () {
                        if (currentIndex > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      gradientColors: const [
                        Colors.white,
                        Color(0xFFF5F5F5),
                      ],
                      size: 70.0,
                      iconSize: 40.0,
                      holdDuration: const Duration(seconds: 1),
                    ),
                  ),
                if (kIsWeb)
                  Positioned(
                    right: 20.0,
                    top: MediaQuery.of(context).size.height / 2 - 35,
                    child: HoldButton(
                      iconBuilder: () => Icons.arrow_forward_ios_rounded,
                      onHold: () {
                        if (currentIndex < assets.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      gradientColors: const [
                        Colors.white,
                        Color(0xFFF5F5F5),
                      ],
                      size: 70.0,
                      iconSize: 40.0,
                      holdDuration: const Duration(seconds: 1),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _speakCurrentTitle(List<UniversAssetModel> assets) {
    final appState = Provider.of<AppState>(context, listen: false);
    final title = assets[currentIndex].translations?[appState.selectedLanguage] ?? assets[currentIndex].title ?? '';
    if (title.isNotEmpty) {
      _tts?.setLanguage(appState.selectedLanguage);
      // Essayer de définir une voix plus naturelle pour la langue
      final voiceName = preferredVoices[appState.selectedLanguage];
      if (voiceName != null) {
        _tts?.setVoice({'name': voiceName, 'locale': appState.selectedLanguage});
      }
      _tts?.speak(title);
    }
  }

  Future<void> playVideo(String videoUrl) async {
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await videoPlayerController?.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        allowFullScreen: false,
        allowMuting: true,
        aspectRatio: videoPlayerController!.value.aspectRatio,
      );

      // Petite pause pour transition fluide
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        isPlayingVideo = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (chewieController != null && isMuted) {
          chewieController?.setVolume(0.0);
        }
      });
    } catch (e) {
      // Ignore video initialization errors
    }
  }
}